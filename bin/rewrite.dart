import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
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
      final dartFile = file as File;
      final source = await dartFile.readAsString();
      final result = await session.getResolvedUnit(dartFile.path) as ResolvedUnitResult;
      
      final library = result.libraryElement2;
      final libraryReader = LibraryReader(library);

      final wrapperSpecs = collectWrappers(libraryReader, generatorOptions);
      if (wrapperSpecs.isEmpty) {
        continue;
      }

      final visitor = WidgetVisitor(wrapperSpecs);
      result.unit.accept(visitor);

      if (visitor.changes.isNotEmpty) {
        final newSource = _applyChanges(source, visitor.changes);
        final formatter = DartFormatter(
          languageVersion:
              _languageVersionFor(result.unit),
        );
        await dartFile.writeAsString(formatter.format(newSource));
        stdout.writeln('Rewrote ${p.relative(dartFile.path)}');
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

Version _languageVersionFor(CompilationUnit unit) {
  final token = unit.languageVersionToken;
  if (token != null) {
    return Version(token.major, token.minor, 0);
  }
  return DartFormatter.latestLanguageVersion;
}
