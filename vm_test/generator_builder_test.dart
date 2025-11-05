@TestOn('vm')
import 'dart:io';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:semantic_gen/src/builder.dart';
import 'package:test/test.dart';

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

      final packageAssets = _packageSourceAssets();
      final writer = TestReaderWriter(rootPackage: 'semantic_gen');
      final result = await testBuilder(
        autoTagBuilder(BuilderOptions(const <String, Object?>{})),
        {
          ...packageAssets,
          'semantic_gen|lib/sample.dart': input,
          'flutter|lib/widgets.dart': _flutterWidgetsStub,
        },
        rootPackage: 'semantic_gen',
        readerWriter: writer,
      );

      final outputPaths =
          result.buildResult.outputs.map((asset) => asset.path).toList();
      expect(
        outputPaths.any(
          (path) => path.contains('sample.semantic_gen.g.part'),
        ),
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

      final packageAssets = _packageSourceAssets();
      final writer = TestReaderWriter(rootPackage: 'semantic_gen');
      final result = await testBuilder(
        autoTagBuilder(BuilderOptions(const <String, Object?>{})),
        {
          ...packageAssets,
          'semantic_gen|lib/sample.dart': input,
          'flutter|lib/widgets.dart': _flutterWidgetsStub,
        },
        rootPackage: 'semantic_gen',
        readerWriter: writer,
      );

      final outputPaths =
          result.buildResult.outputs.map((asset) => asset.path).toList();
      expect(
        outputPaths.any(
          (path) => path.contains('sample.semantic_gen.g.part'),
        ),
        isTrue,
        reason: 'outputs: $outputPaths',
      );
    });
  });
}

const String _flutterWidgetsStub = '''
library widgets;

class Widget {
  const Widget({Key? key});
}

class StatelessWidget extends Widget {
  const StatelessWidget({super.key});

  Widget build(BuildContext context) => throw UnimplementedError();
}

class BuildContext {}

class Key {
  const Key(String value);
}

class Text extends StatelessWidget {
  const Text(String data, {super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class Semantics extends StatelessWidget {
  const Semantics({
    super.key,
    required Widget child,
    String? label,
    bool? container,
    bool? button,
    bool? textField,
    bool? enabled,
  });
}
''';

Map<String, String> _packageSourceAssets() {
  String read(String relativePath) =>
      File(relativePath).readAsStringSync();

  return <String, String>{
    'semantic_gen|lib/semantic_gen.dart':
        read('lib/semantic_gen.dart'),
    'semantic_gen|lib/semantic_gen.tagged.g.dart':
        read('lib/semantic_gen.tagged.g.dart'),
    'semantic_gen|lib/src/annotations.dart':
        read('lib/src/annotations.dart'),
    'semantic_gen|lib/src/runtime.dart':
        read('lib/src/runtime.dart'),
  };
}
