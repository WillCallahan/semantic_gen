// ignore_for_file: unnecessary_library_name

@TestOn('vm')
library custom_wrapper_test;

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:semantic_gen/src/builder.dart';
import 'package:test/test.dart';
import 'test_fixtures.dart';

void main() {
  group('AutoTagGenerator with custom templates', () {
    test('uses custom template when provided', () async {
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
            
            @AutoTag(
              custom: WrapperTemplate('MyWrapper(child: {{child}})')
            )
            class ProfileHeader {}
          ''',
        },
        outputs: {
          ..._dependencyOutputs(),
          'a|lib/a.semgen.dart': decodedMatches(
            allOf(
              contains('class ProfileHeaderTagged'),
              contains('return MyWrapper(child: child);'),
            ),
          ),
        },
      );
    });

    test('uses custom template for library-level widgets', () async {
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
            @AutoWrapWidgets(
              ['MyButton'],
              WrapperTemplate('MyWrapper(child: {{child}})')
            )
            library my_lib;

            import 'package:semantic_gen/semantic_gen.dart';
          ''',
        },
        outputs: {
          ..._dependencyOutputs(),
          'a|lib/a.semgen.dart': decodedMatches(
            allOf(
              contains('class MyButtonTagged'),
              contains('return MyWrapper(child: child);'),
            ),
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
