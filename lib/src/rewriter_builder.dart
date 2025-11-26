import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'collector.dart';
import 'rewriter.dart';

/// A [Builder] that rewrites Dart files.
class RewriterBuilder implements Builder {
  /// Creates a [RewriterBuilder].
  const RewriterBuilder(this.options);

  final GeneratorOptions options;

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dart': ['.rewritten.dart'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;

    if (!await buildStep.resolver.isLibrary(inputId) ||
        inputId.path.endsWith('.g.dart') ||
        inputId.path.endsWith('.semgen.dart')) {
      return;
    }

    final resolver = buildStep.resolver;
    final library = await resolver.libraryFor(inputId);
    final libraryReader = LibraryReader(library);

    final collector = WidgetCollector(options);
    final wrapperSpecs = await collector.collect(libraryReader, buildStep);

    if (wrapperSpecs.isEmpty) {
      return;
    }

    final parsedResult = await resolver.getParsedLibraryResult(inputId);
    final unit = parsedResult.unit;
    final source = parsedResult.content;

    final visitor = WidgetVisitor(wrapperSpecs);
    unit.accept(visitor);

    if (visitor.changes.isNotEmpty) {
      final newSource = _applyChanges(source, visitor.changes);
      final formatter = DartFormatter();
      await buildStep.writeAsString(
        inputId.changeExtension('.rewritten.dart'),
        formatter.format(newSource),
      );
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
}
