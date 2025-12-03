// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:pub_semver/pub_semver.dart';
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

    final source = await buildStep.readAsString(inputId);
    final unit = await resolver.compilationUnitFor(
      inputId,
      allowSyntaxErrors: true,
    );

    final visitor = WidgetVisitor(wrapperSpecs);
    unit.accept(visitor);

    if (visitor.changes.isNotEmpty) {
      final newSource = _applyChanges(source, visitor.changes);
      final formatter = DartFormatter(
        languageVersion: _languageVersionFor(unit),
      );
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

  Version _languageVersionFor(CompilationUnit unit) {
    final token = unit.languageVersionToken;
    if (token != null) {
      return Version(token.major, token.minor, 0);
    }
    return DartFormatter.latestLanguageVersion;
  }
}
