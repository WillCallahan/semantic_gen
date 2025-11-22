import 'dart:io';

/// Minimal Flutter widgets stub used by build_test.
const String flutterWidgetsStub = '''
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
  const Text(String data, {super.key, TextAlign? textAlign});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

enum TextAlign { center }

class SelectableText extends StatelessWidget {
  const SelectableText(String data, {super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class TextField extends StatelessWidget {
  const TextField({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class TextFormField extends StatelessWidget {
  const TextFormField({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class GestureDetector extends StatelessWidget {
  const GestureDetector({super.key, required Widget child});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class InkWell extends StatelessWidget {
  const InkWell({super.key, required Widget child});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class InkResponse extends StatelessWidget {
  const InkResponse({super.key, required Widget child});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class RawMaterialButton extends StatelessWidget {
  const RawMaterialButton({super.key, required Widget child});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class ElevatedButton extends StatelessWidget {
  const ElevatedButton({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class FilledButton extends StatelessWidget {
  const FilledButton({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class OutlinedButton extends StatelessWidget {
  const OutlinedButton({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class TextButton extends StatelessWidget {
  const TextButton({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class IconButton extends StatelessWidget {
  const IconButton({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class FloatingActionButton extends StatelessWidget {
  const FloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class DropdownButton extends StatelessWidget {
  const DropdownButton({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class PopupMenuButton extends StatelessWidget {
  const PopupMenuButton({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class MenuItemButton extends StatelessWidget {
  const MenuItemButton({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class ListTile extends StatelessWidget {
  const ListTile({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class CheckboxListTile extends StatelessWidget {
  const CheckboxListTile({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class SwitchListTile extends StatelessWidget {
  const SwitchListTile({super.key});

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

class RadioListTile extends StatelessWidget {
  const RadioListTile({super.key});

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

Map<String, String> packageSourceAssets() {
  String read(String relativePath) => File(relativePath).readAsStringSync();

  return <String, String>{
    'semantic_gen|lib/semantic_gen.dart': read('lib/semantic_gen.dart'),
    'semantic_gen|lib/semantic_gen.tagged.g.dart': read(
      'lib/semantic_gen.tagged.g.dart',
    ),
    'semantic_gen|lib/src/annotations.dart': read('lib/src/annotations.dart'),
    'semantic_gen|lib/src/runtime.dart': read('lib/src/runtime.dart'),
  };
}
