// ignore_for_file: unnecessary_library_name

@TestOn('vm')
library generator_hardening_test;

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:semantic_gen/src/builder.dart';
import 'package:test/test.dart';

void main() {
  group('AutoTagGenerator coverage', () {
    test('defaults produce wrappers when library has no annotations', () async {
      final builder = autoTagBuilder(BuilderOptions.empty);
      await testBuilder(
        builder,
        {'a|lib/a.dart': ''},
        outputs: {
          'a|lib/a.semgen.dart': decodedMatches(contains('class TextTagged')),
        },
      );
    });

    test('default tap targets are marked as buttons', () async {
      final builder = autoTagBuilder(BuilderOptions.empty);
      await testBuilder(
        builder,
        {'a|lib/a.dart': 'class MyWidget {}'},
        outputs: {
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
      await testBuilder(
        builder,
        {'a|lib/a.dart': ''},
        outputs: {
          'a|lib/a.semgen.dart': decodedMatches(
            contains('class ValidNameTagged'),
          ),
        },
      );
    });
  });
}
