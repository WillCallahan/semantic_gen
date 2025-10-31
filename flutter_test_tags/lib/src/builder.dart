import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generator.dart';

/// Creates the build_runner builder that drives the semantics generator.
Builder autoTagBuilder(BuilderOptions options) {
  final generatorOptions = AutoTagGenerator.parseConfig(options.config);
  return SharedPartBuilder(
    [AutoTagGenerator(generatorOptions)],
    'flutter_test_tags',
  );
}
