// ignore_for_file: unnecessary_library_name

@TestOn('vm')
library generator_test;

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:semantic_gen/src/builder.dart';
import 'package:test/test.dart';

void main() {
  group('AutoTagGenerator', () {
    test('includes defaults and annotated classes', () async {
      final builder = autoTagBuilder(BuilderOptions.empty);
      await testBuilder(
        builder,
        {
          'a|lib/a.dart': '''
            import 'package:semantic_gen/semantic_gen.dart';
            
            @AutoTag()
            class ProfileHeader {}
          ''',
        },
        outputs: {
          'a|lib/a.semgen.dart': decodedMatches(
            contains('class ProfileHeaderTagged'),
          ),
        },
      );
    });

    test('prefers testId when provided', () async {
      final builder = autoTagBuilder(BuilderOptions.empty);
      await testBuilder(
        builder,
        {
          'a|lib/a.dart': '''
            import 'package:semantic_gen/semantic_gen.dart';
            
            @AutoTag()
            @TestId('login-button')
            class LoginButton {}
          ''',
        },
        outputs: {
          'a|lib/a.semgen.dart': decodedMatches(
            contains("label: 'test:login-button'"),
          ),
        },
      );
    });

    test('merges library widget names with global config', () async {
      final builder = autoTagBuilder(
        const BuilderOptions({
          'auto_wrap_widgets': ['DropdownButton'],
        }),
      );
      await testBuilder(
        builder,
        {
          'a|lib/a.dart': '''
            import 'package:semantic_gen/semantic_gen.dart';
            
            @AutoWrapWidgets(widgetTypes: ['ElevatedButton'])
            library my_lib;
          ''',
        },
        outputs: {
          'a|lib/a.semgen.dart': decodedMatches(
            allOf(
              contains('class DropdownButtonTagged'),
              contains('class ElevatedButtonTagged'),
            ),
          ),
        },
      );
    });

    test('respects custom prefix', () async {
      final builder = autoTagBuilder(const BuilderOptions({'prefix': 'qa'}));
      await testBuilder(
        builder,
        {
          'a|lib/a.dart': '''
            import 'package:semantic_gen/semantic_gen.dart';
            
            @AutoTag()
            class ProfileHeader {}
          ''',
        },
        outputs: {
          'a|lib/a.semgen.dart': decodedMatches(
            contains("label: 'qa:auto:ProfileHeader'"),
          ),
        },
      );
    });
  });
}
