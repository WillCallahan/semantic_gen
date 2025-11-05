@TestOn('vm')
import 'package:semantic_gen/src/generator.dart';
import 'package:test/test.dart';

const bool _isFlutterTest = bool.fromEnvironment('dart.library.ui');

void main() {
  if (_isFlutterTest) {
    return;
  }
  group('AutoTagGenerator', () {
    late AutoTagGenerator generator;

    setUp(() {
      generator = const AutoTagGenerator(GeneratorOptions());
    });

    test('includes defaults and annotated classes', () {
      final wrappers = generator.collectWrappersForTesting(
        classDescriptors: [
          generator.describeClassForTest(
            name: 'ProfileHeader',
            namespace: 'profile',
          ),
        ],
      );

      expect(
        wrappers.map((wrapper) => wrapper.wrapperName),
        contains('ProfileHeaderTagged'),
      );
      expect(
        wrappers.any(
          (wrapper) =>
              wrapper.wrapperName == 'ProfileHeaderTagged' &&
              wrapper.semanticsLabel == 'test:profile:ProfileHeader',
        ),
        isTrue,
      );
      expect(
        wrappers.map((wrapper) => wrapper.wrapperName),
        contains('TextTagged'),
      );
    });

    test('prefers testId when provided', () {
      final wrappers = generator.collectWrappersForTesting(
        classDescriptors: [
          generator.describeClassForTest(
            name: 'LoginButton',
            namespace: 'auth',
            testId: 'login-button',
            isButton: true,
          ),
        ],
      );

      final loginWrapper = wrappers.singleWhere(
        (wrapper) => wrapper.wrapperName == 'LoginButtonTagged',
      );
      expect(loginWrapper.semanticsLabel, 'test:login-button');
      expect(loginWrapper.button, isTrue);
    });

    test('merges library widget names with global config', () {
      final configuredGenerator = AutoTagGenerator(
        const GeneratorOptions(globalWidgets: ['DropdownButton']),
      );

      final wrappers = configuredGenerator.collectWrappersForTesting(
        libraryWidgetNames: const ['ElevatedButton'],
      );

      expect(
        wrappers.map((wrapper) => wrapper.wrapperName),
        containsAll(<String>['DropdownButtonTagged', 'ElevatedButtonTagged']),
      );
    });

    test('respects custom prefix', () {
      final configuredGenerator = AutoTagGenerator(
        const GeneratorOptions(prefix: 'qa'),
      );

      final wrappers = configuredGenerator.collectWrappersForTesting(
        classDescriptors: [
          configuredGenerator.describeClassForTest(name: 'ProfileHeader'),
        ],
      );

      final profileWrapper = wrappers.singleWhere(
        (wrapper) => wrapper.wrapperName == 'ProfileHeaderTagged',
      );
      expect(profileWrapper.semanticsLabel, 'qa:auto:ProfileHeader');
    });
  });
}
