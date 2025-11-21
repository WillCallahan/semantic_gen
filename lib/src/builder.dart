import 'dart:async';

import 'package:build/build.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:source_gen/source_gen.dart';

import 'collector.dart';

/// Creates the build_runner builder that drives the semantics generator.
Builder autoTagBuilder(BuilderOptions options) {
  final generatorOptions = GeneratorOptions.parseConfig(options.config);
  return SemanticGeneratorBuilder(generatorOptions);
}

/// A builder that generates semantic wrappers for widgets.
class SemanticGeneratorBuilder implements Builder {
  /// Creates a new [SemanticGeneratorBuilder].
  SemanticGeneratorBuilder(this.options);

  /// The options for the generator.
  final GeneratorOptions options;

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.semgen.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;

    final library = await buildStep.inputLibrary;
    final libraryReader = LibraryReader(library);

    final collector = WidgetCollector(options);
    final wrappers = await collector.collect(libraryReader, buildStep);

    if (wrappers.isEmpty) {
      final outputId = buildStep.inputId.changeExtension('.semgen.dart');
      await buildStep.writeAsString(
        outputId,
        await buildStep.readAsString(buildStep.inputId),
      );
      return;
    }

    final wrapperMap = {for (var v in wrappers) v.typeName: v};

    final compilationUnit = await resolver.compilationUnitFor(
      buildStep.inputId,
    );
    final source = await buildStep.readAsString(buildStep.inputId);

    final importVisitor = _ImportVisitor();
    compilationUnit.accept(importVisitor);

    final widgetVisitor = _WidgetWrapperVisitor(source, wrapperMap);
    compilationUnit.accept(widgetVisitor);

    if (widgetVisitor.edits.isEmpty) {
      final outputId = buildStep.inputId.changeExtension('.semgen.dart');
      await buildStep.writeAsString(outputId, source);
      return;
    }

    var newSource = source;
    final edits = widgetVisitor.edits;
    edits.sort((a, b) => b.offset.compareTo(a.offset));

    for (final edit in edits) {
      newSource =
          newSource.substring(0, edit.offset) +
          edit.replacement +
          newSource.substring(edit.offset + edit.length);
    }

    if (!importVisitor.hasWidgetsImport) {
      newSource = "import 'package:flutter/widgets.dart';\n\n$newSource";
    }

    final outputId = buildStep.inputId.changeExtension('.semgen.dart');
    await buildStep.writeAsString(outputId, newSource);
  }
}

class _SourceEdit {
  _SourceEdit(this.offset, this.length, this.replacement);
  final int offset;
  final int length;
  final String replacement;
}

class _WidgetWrapperVisitor extends RecursiveAstVisitor<void> {
  _WidgetWrapperVisitor(this.source, this.wrapperMap);

  final String source;
  final Map<String, WrapperSpec> wrapperMap;
  final edits = <_SourceEdit>[];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.constructorName.type;
    final typeName = type.name2.lexeme;

    final spec = wrapperMap[typeName];

    if (spec != null) {
      final originalSource = source.substring(node.offset, node.end);
      final replacement = '''
  Semantics(
    label: '${spec.semanticsLabel}',
    container: ${spec.container},
    button: ${spec.button},
    textField: ${spec.textField},
    enabled: ${spec.enabled},
    child: $originalSource,
  )''';
      edits.add(_SourceEdit(node.offset, node.length, replacement));
    }
    super.visitInstanceCreationExpression(node);
  }
}

class _ImportVisitor extends RecursiveAstVisitor<void> {
  bool hasWidgetsImport = false;

  @override
  void visitImportDirective(ImportDirective node) {
    if (node.uri.stringValue == 'package:flutter/widgets.dart') {
      hasWidgetsImport = true;
    }
    super.visitImportDirective(node);
  }
}
