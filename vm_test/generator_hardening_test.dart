@TestOn('vm')
import 'package:semantic_gen/src/generator.dart';
import 'package:test/test.dart';

void main() {
  group('AutoTagGenerator coverage', () {
    test('defaults produce wrappers when library has no annotations', () {
      final generator = const AutoTagGenerator(GeneratorOptions());
      final wrappers = generator.collectWrappersForTesting();

      expect(wrappers, isNotEmpty);
      expect(wrappers.map((wrapper) => wrapper.wrapperName),
          containsAll(<String>['TextTagged', 'SelectableTextTagged', 'TextFieldTagged', 'TextFormFieldTagged']));
    });

    test('sanitizes invalid identifiers and logs warning', () {
      final generator = const AutoTagGenerator(GeneratorOptions());
      final wrappers = generator.collectWrappersForTesting(
        libraryWidgetNames: const ['ValidName', 'Invalid Name', '1NotAnIdentifier'],
      );

      expect(wrappers.map((wrapper) => wrapper.wrapperName), contains('ValidNameTagged'));
      expect(wrappers, isNot(contains('Invalid NameTagged')));
    });

    test('merges descriptors respecting testId overrides and flags', () {
      final generator = const AutoTagGenerator(GeneratorOptions(prefix: 'qa'));
      final wrappers = generator.collectWrappersForTesting(
        classDescriptors: [
          generator.describeClassForTest(
            name: 'CheckoutButton',
            namespace: 'checkout',
            testId: 'checkout-button',
            isButton: true,
          ),
          generator.describeClassForTest(
            name: 'SearchField',
            namespace: 'forms',
            isTextField: true,
          ),
        ],
      );

      final button = wrappers.singleWhere((wrapper) => wrapper.wrapperName == 'CheckoutButtonTagged');
      expect(button.semanticsLabel, 'qa:checkout-button');
      expect(button.button, isTrue);
      expect(button.textField, isFalse);

      final field = wrappers.singleWhere((wrapper) => wrapper.wrapperName == 'SearchFieldTagged');
      expect(field.semanticsLabel, 'qa:forms:SearchField');
      expect(field.textField, isTrue);
    });

    test('extracts widget names from AutoWrapWidgets annotations', () {
      final names = AutoTagGenerator.widgetNamesFromStrings(
        const ['ElevatedButton', null, ''],
      ).toList();

      expect(names, contains('ElevatedButton'));
      expect(names.length, 1);
    });

    test('descriptorFromMetadata normalizes optional values', () {
      final generator = const AutoTagGenerator(GeneratorOptions());
      final descriptor = generator.descriptorFromMetadata(
        className: 'CheckoutButton',
        namespace: '',
        testId: 'checkout-button',
        isButton: true,
        isTextField: false,
      );

      expect(descriptor.name, 'CheckoutButton');
      expect(descriptor.namespace, isNull);
      expect(descriptor.testId, 'checkout-button');
      expect(descriptor.isButton, isTrue);
      expect(descriptor.isTextField, isFalse);
    });
  });
}
