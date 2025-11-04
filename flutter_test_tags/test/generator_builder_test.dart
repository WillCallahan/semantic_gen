@TestOn('vm')
import 'dart:io';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:flutter_test_tags/src/builder.dart';
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
import 'package:flutter_test_tags/flutter_test_tags.dart';

part 'sample.tagged.g.dart';

@AutoTag('profile')
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) => const Text('Profile');
}
''';

      final packageAssets = _packageSourceAssets();
      final writer = TestReaderWriter(rootPackage: 'flutter_test_tags');
      final result = await testBuilder(
        autoTagBuilder(BuilderOptions(const <String, Object?>{})),
        {
          ...packageAssets,
          'flutter_test_tags|lib/sample.dart': input,
          'flutter|lib/widgets.dart': _flutterWidgetsStub,
        },
        rootPackage: 'flutter_test_tags',
        readerWriter: writer,
      );

      final outputPaths =
          result.buildResult.outputs.map((asset) => asset.path).toList();
      expect(
        outputPaths.any(
          (path) => path.contains('sample.flutter_test_tags.g.part'),
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
import 'package:flutter_test_tags/flutter_test_tags.dart';

part 'sample.tagged.g.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) => const Text('Demo');
}
''';

      final packageAssets = _packageSourceAssets();
      final writer = TestReaderWriter(rootPackage: 'flutter_test_tags');
      final result = await testBuilder(
        autoTagBuilder(BuilderOptions(const <String, Object?>{})),
        {
          ...packageAssets,
          'flutter_test_tags|lib/sample.dart': input,
          'flutter|lib/widgets.dart': _flutterWidgetsStub,
        },
        rootPackage: 'flutter_test_tags',
        readerWriter: writer,
      );

      final outputPaths =
          result.buildResult.outputs.map((asset) => asset.path).toList();
      expect(
        outputPaths.any(
          (path) => path.contains('sample.flutter_test_tags.g.part'),
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
    'flutter_test_tags|lib/flutter_test_tags.dart':
        read('lib/flutter_test_tags.dart'),
    'flutter_test_tags|lib/flutter_test_tags.tagged.g.dart':
        read('lib/flutter_test_tags.tagged.g.dart'),
    'flutter_test_tags|lib/src/annotations.dart':
        read('lib/src/annotations.dart'),
    'flutter_test_tags|lib/src/runtime.dart':
        read('lib/src/runtime.dart'),
  };
}
