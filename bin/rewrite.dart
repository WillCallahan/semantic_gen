import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;
import 'package:semantic_gen/src/collector.dart';
import 'package:semantic_gen/src/rewriter.dart';
import 'package:semantic_gen/src/wrapper_collector.dart';
import 'package:source_gen/source_gen.dart';

Future<void> main(List<String> args) async {
  final target = args.isNotEmpty ? args.first : '.';
  final libDir = p.join(target, 'lib');
  final glob = Glob('**/*.dart');

  // For now, hardcode the options.
  // A proper implementation would read this from build.yaml.
  const generatorOptions = GeneratorOptions();

  final collection = AnalysisContextCollection(includedPaths: [p.canonicalize(target)]);
  final session = collection.contextFor(p.canonicalize(target)).currentSession;

  await for (final file in glob.list(root: libDir)) {
    if (file is File) {
      final source = await file.readAsString();
      final result = await session.getResolvedUnit(file.path) as ResolvedUnitResult;
      
      final library = result.libraryElement;
      final libraryReader = LibraryReader(library);

      final wrapperSpecs = collectWrappers(libraryReader, generatorOptions);
      if (wrapperSpecs.isEmpty) {
        continue;
      }

      final visitor = WidgetVisitor(wrapperSpecs);
      result.unit.accept(visitor);

      if (visitor.changes.isNotEmpty) {
        final newSource = _applyChanges(source, visitor.changes);
        final formatter = DartFormatter();
        await file.writeAsString(formatter.format(newSource));
        print('Rewrote ${p.relative(file.path)}');
      }
    }
  }
}

String _applyChanges(String source, List<Change> changes) {
  changes.sort((a, b) => b.offset.compareTo(a.offset));
  var newSource = source;
  for (final change in changes) {
    newSource = newSource.replaceRange(
      change.offset,
      change.offset + change.length,
      change.replacement,
    );
  }
  return newSource;
}
