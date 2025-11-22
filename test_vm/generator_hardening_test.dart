// ignore_for_file: unnecessary_library_name

@TestOn('vm')
library generator_hardening_test;

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:semantic_gen/src/builder.dart';
import 'package:test/test.dart';
import 'test_fixtures.dart';

void main() {
  group('AutoTagGenerator coverage', () {
    test('defaults produce wrappers when library has no annotations', () async {
      final builder = autoTagBuilder(BuilderOptions.empty);
      final assets = {
        ...packageSourceAssets(),
        'flutter|lib/widgets.dart': flutterWidgetsStub,
      };
      await testBuilder(
        builder,
        {...assets, 'a|lib/a.dart': ''},
        outputs: {
          ..._dependencyOutputs(),
          'a|lib/a.semgen.dart': decodedMatches(contains('class TextTagged')),
        },
      );
    });

    test('default tap targets are marked as buttons', () async {
      final builder = autoTagBuilder(BuilderOptions.empty);
      final assets = {
        ...packageSourceAssets(),
        'flutter|lib/widgets.dart': flutterWidgetsStub,
      };
      await testBuilder(
        builder,
        {...assets, 'a|lib/a.dart': 'class MyWidget {}'},
        outputs: {
          ..._dependencyOutputs(),
          'a|lib/a.semgen.dart': decodedMatches(contains('button: true,')),
        },
      );
    });

    test('sanitizes invalid identifiers and logs warning', () async {
      final builder = autoTagBuilder(
        const BuilderOptions({
          'auto_wrap_widgets': [
            'ValidName',
            'Invalid Name',
            '1NotAnIdentifier',
          ],
        }),
      );
      final assets = {
        ...packageSourceAssets(),
        'flutter|lib/widgets.dart': flutterWidgetsStub,
      };
      await testBuilder(
        builder,
        {...assets, 'a|lib/a.dart': ''},
        outputs: {
          ..._dependencyOutputs(),
          'a|lib/a.semgen.dart': decodedMatches(
            contains('class ValidNameTagged'),
          ),
        },
      );
    });
  });
}

Map<String, Object> _dependencyOutputs() => <String, Object>{
  'flutter|lib/widgets.semgen.dart': anything,
  'semantic_gen|lib/semantic_gen.semgen.dart': anything,
  'semantic_gen|lib/src/annotations.semgen.dart': anything,
  'semantic_gen|lib/src/runtime.semgen.dart': anything,
};
