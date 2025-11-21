// ignore_for_file: unnecessary_library_name

@TestOn('vm')
library generator_config_test;

import 'package:semantic_gen/src/collector.dart';
import 'package:test/test.dart';

void main() {
  group('GeneratorOptions', () {
    test('parseConfig reads prefix and widget list', () {
      final options = GeneratorOptions.parseConfig({
        'auto_wrap_widgets': ['ElevatedButton', 42],
        'prefix': 'qa',
      });

      expect(options.prefix, 'qa');
      expect(options.globalWidgets, ['ElevatedButton', '42']);
    });

    test('parseConfig falls back to defaults', () {
      final options = GeneratorOptions.parseConfig({
        'auto_wrap_widgets': 'not a list',
        'prefix': '',
      });

      expect(options.prefix, 'test');
      expect(options.globalWidgets, isEmpty);
    });
  });
}
