// ignore_for_file: unnecessary_library_name

@TestOn('vm')
library generator_test;

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:semantic_gen/src/builder.dart';
import 'package:test/test.dart';
import 'test_fixtures.dart';

void main() {
  group('AutoTagGenerator', () {
    test('includes defaults and annotated classes', () async {
      final builder = autoTagBuilder(BuilderOptions.empty);
      final assets = {
        ...packageSourceAssets(),
        'flutter|lib/widgets.dart': flutterWidgetsStub,
      };
      await testBuilder(
        builder,
        {
          ...assets,
          'a|lib/a.dart': '''
            import 'package:semantic_gen/semantic_gen.dart';
            
            @AutoTag()
            class ProfileHeader {}
          ''',
        },
        outputs: {
          ..._dependencyOutputs(),
          'a|lib/a.semgen.dart': decodedMatches(
            contains('class ProfileHeaderTagged'),
          ),
        },
      );
    });

    test('prefers testId when provided', () async {
      final builder = autoTagBuilder(BuilderOptions.empty);
      final assets = {
        ...packageSourceAssets(),
        'flutter|lib/widgets.dart': flutterWidgetsStub,
      };
      await testBuilder(
        builder,
        {
          ...assets,
          'a|lib/a.dart': '''
            import 'package:semantic_gen/semantic_gen.dart';
            
            @AutoTag()
            @TestId('login-button')
            class LoginButton {}
          ''',
        },
        outputs: {
          ..._dependencyOutputs(),
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
      final assets = {
        ...packageSourceAssets(),
        'flutter|lib/widgets.dart': flutterWidgetsStub,
      };
      await testBuilder(
        builder,
        {
          ...assets,
          'a|lib/a.dart': '''
            @AutoWrapWidgets(widgetTypes: ['ElevatedButton'])
            library my_lib;

            import 'package:semantic_gen/semantic_gen.dart';
            
          ''',
        },
        outputs: {
          ..._dependencyOutputs(),
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
      final assets = {
        ...packageSourceAssets(),
        'flutter|lib/widgets.dart': flutterWidgetsStub,
      };
      await testBuilder(
        builder,
        {
          ...assets,
          'a|lib/a.dart': '''
            import 'package:semantic_gen/semantic_gen.dart';
            
            @AutoTag()
            class ProfileHeader {}
          ''',
        },
        outputs: {
          ..._dependencyOutputs(),
          'a|lib/a.semgen.dart': decodedMatches(
            contains("label: 'qa:auto:ProfileHeader'"),
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
