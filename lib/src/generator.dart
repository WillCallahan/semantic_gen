import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'collector.dart';

/// Collects and emits wrappers that add deterministic semantics labels.
class AutoTagGenerator extends Generator {
  /// Creates a new generator.
  AutoTagGenerator(this._baseOptions);

  final GeneratorOptions _baseOptions;

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final collector = WidgetCollector(_baseOptions);
    final wrappers = await collector.collect(library, buildStep);

    final buffer = _createBuffer(buildStep);

    if (wrappers.isEmpty) {
      return buffer.toString();
    }

    if (!_baseOptions.enabled) {
      buffer.writeln('// semantic_gen disabled via configuration.');
      return buffer.toString();
    }

    for (final wrapper in wrappers) {
      buffer
        ..writeln('class ${wrapper.wrapperName} extends StatelessWidget {')
        ..writeln(
          '  const ${wrapper.wrapperName}({Key? key, required this.child}) : super(key: key);',
        )
        ..writeln()
        ..writeln('  final ${wrapper.typeName} child;')
        ..writeln()
        ..writeln('  @override')
        ..writeln('  Widget build(BuildContext context) {')
        ..writeln('    return Semantics(')
        ..writeln("      label: '${wrapper.semanticsLabel}',")
        ..writeln('      container: ${wrapper.container},')
        ..writeln('      button: ${wrapper.button},')
        ..writeln('      textField: ${wrapper.textField},')
        ..writeln('      enabled: ${wrapper.enabled},')
        ..writeln('      child: child,')
        ..writeln('    );')
        ..writeln('  }')
        ..writeln('}')
        ..writeln();
    }

    return buffer.toString();
  }

  StringBuffer _createBuffer(BuildStep buildStep) {
    final library = buildStep.inputId.pathSegments.first;
    return StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
      ..writeln('// coverage:ignore-file')
      ..writeln('// ignore_for_file: type=lint')
      ..writeln()
      ..writeln("part of '$library';")
      ..writeln()
      ..writeln("import 'package:flutter/widgets.dart';")
      ..writeln();
  }
}
