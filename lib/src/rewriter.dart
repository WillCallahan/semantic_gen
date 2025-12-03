// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:collection/collection.dart';
import 'package:semantic_gen/src/collector.dart';

class Change {
  Change(this.offset, this.length, this.replacement);

  final int offset;
  final int length;
  final String replacement;
}

class WidgetVisitor extends RecursiveAstVisitor<void> {
  WidgetVisitor(this.wrapperSpecs);

  final List<WrapperSpec> wrapperSpecs;
  final List<Change> changes = [];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    final typeAnnotation = node.constructorName.type;
    final typeName = typeAnnotation.name2.lexeme;
    final wrapper = wrapperSpecs.firstWhereOrNull(
      (spec) => spec.typeName == typeName,
    );

    if (wrapper != null) {
      final replacement = '${wrapper.wrapperName}(child: ${node.toSource()})';
      changes.add(Change(node.offset, node.length, replacement));
    }
  }
}
