import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'collector.dart';
import 'generator.dart';

/// Creates the build_runner builder that drives the semantics generator.
Builder autoTagBuilder(BuilderOptions options) {
  final generatorOptions = GeneratorOptions.parseConfig(options.config);
  return _SemanticGeneratorBuilder(generatorOptions);
}

/// A builder that emits tagged wrappers alongside each Dart library.
class _SemanticGeneratorBuilder implements Builder {
  _SemanticGeneratorBuilder(this.options);

  /// The options for the generator.
  final GeneratorOptions options;

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.semgen.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    final library = await buildStep.inputLibrary;
    final libraryReader = LibraryReader(library);

    final generator = AutoTagGenerator(options);
    final output = await generator.generate(libraryReader, buildStep);

    final outputId = buildStep.inputId.changeExtension('.semgen.dart');
    await buildStep.writeAsString(outputId, output);
  }
}
