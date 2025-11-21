// ignore_for_file: unnecessary_library_name, invalid_use_of_visible_for_testing_member

@TestOn('vm')
library generator_config_test;

import 'package:semantic_gen/src/generator.dart';
import 'package:test/test.dart';

void main() {
  group('GeneratorOptions', () {
    test('parseConfig reads prefix and widget list', () {
      final options = AutoTagGenerator.parseConfig({
        'auto_wrap_widgets': ['ElevatedButton', 42],
        'prefix': 'qa',
      });

      expect(options.prefix, 'qa');
      expect(options.globalWidgets, ['ElevatedButton', '42']);
    });

    test('parseConfig falls back to defaults', () {
      final options = AutoTagGenerator.parseConfig({
        'auto_wrap_widgets': 'not a list',
        'prefix': '',
      });

      expect(options.prefix, 'test');
      expect(options.globalWidgets, isEmpty);
    });
  });

  group('Identifier and heuristics', () {
    test('isValidIdentifier validates dart rules', () {
      expect(AutoTagGenerator.isValidIdentifier('Good_Name1'), isTrue);
      expect(AutoTagGenerator.isValidIdentifier('1bad'), isFalse);
      expect(AutoTagGenerator.isValidIdentifier('also bad'), isFalse);
    });

    test('inferButtonFlag considers class name and super types', () {
      expect(AutoTagGenerator.inferButtonFlag(name: 'MyButton'), isTrue);
      expect(
        AutoTagGenerator.inferButtonFlag(
          name: 'SomethingElse',
          superTypes: const ['Widget', 'RawButtonBase'],
        ),
        isTrue,
      );
      expect(AutoTagGenerator.inferButtonFlag(name: 'PlainWidget'), isFalse);
    });

    test('inferTextFieldFlag looks for text-field keywords', () {
      expect(
        AutoTagGenerator.inferTextFieldFlag(name: 'BestTextField'),
        isTrue,
      );
      expect(
        AutoTagGenerator.inferTextFieldFlag(
          name: 'RichEditor',
          superTypes: const ['FormField'],
        ),
        isTrue,
      );
      expect(AutoTagGenerator.inferTextFieldFlag(name: 'PlainWidget'), isFalse);
    });
  });
}
