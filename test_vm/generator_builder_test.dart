// ignore_for_file: unnecessary_library_name, invalid_use_of_visible_for_testing_member

@TestOn('vm')
library generator_builder_test;

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:semantic_gen/src/builder.dart';
import 'package:test/test.dart';

import 'test_fixtures.dart';

const bool _isFlutterTest = bool.fromEnvironment('dart.library.ui');

void main() {
  if (_isFlutterTest) {
    return;
  }

  group('autoTagBuilder integration', () {
    test('generates wrappers and handles annotations', () async {
      const input = '''
library sample;

import 'package:flutter/widgets.dart';
import 'package:semantic_gen/semantic_gen.dart';

part 'sample.tagged.g.dart';

@AutoTag('profile')
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) => const Text('Profile');
}
''';

      final packageAssets = packageSourceAssets();
      final writer = TestReaderWriter(rootPackage: 'semantic_gen');
      final result = await testBuilder(
        autoTagBuilder(BuilderOptions(const <String, Object?>{})),
        {
          ...packageAssets,
          'semantic_gen|lib/sample.dart': input,
          'flutter|lib/widgets.dart': flutterWidgetsStub,
        },
        rootPackage: 'semantic_gen',
        readerWriter: writer,
      );

      final outputPaths =
          result.buildResult.outputs.map((asset) => asset.path).toList();
      expect(
        outputPaths.any((path) => path.contains('sample.semgen.dart')),
        isTrue,
        reason: 'outputs: $outputPaths',
      );
    });

    test('resolves AutoWrapWidgets annotations', () async {
      const input = '''
@AutoWrapWidgets(['ElevatedButton'])
library sample;

import 'package:flutter/widgets.dart';
import 'package:semantic_gen/semantic_gen.dart';

part 'sample.tagged.g.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) => const Text('Demo');
}
''';

      final packageAssets = packageSourceAssets();
      final writer = TestReaderWriter(rootPackage: 'semantic_gen');
      final result = await testBuilder(
        autoTagBuilder(BuilderOptions(const <String, Object?>{})),
        {
          ...packageAssets,
          'semantic_gen|lib/sample.dart': input,
          'flutter|lib/widgets.dart': flutterWidgetsStub,
        },
        rootPackage: 'semantic_gen',
        readerWriter: writer,
      );

      final outputPaths =
          result.buildResult.outputs.map((asset) => asset.path).toList();
      expect(
        outputPaths.any((path) => path.contains('sample.semgen.dart')),
        isTrue,
        reason: 'outputs: $outputPaths',
      );
    });
  });
}
