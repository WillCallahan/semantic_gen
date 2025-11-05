// GENERATED STUB: run `dart run build_runner build -d` to regenerate.
// The real output is produced by the semantic_gen generator.

part of 'semantic_gen.dart';

/// Placeholder wrapper for [Text] widgets prior to code generation.
class TextTagged extends StatelessWidget {
  /// Creates a [TextTagged] widget.
  const TextTagged({super.key, required this.child});

  /// The original [Text] widget.
  final Text child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'test:auto:Text',
      container: true,
      enabled: true,
      child: child,
    );
  }
}

/// Placeholder wrapper for [SelectableText] widgets prior to code generation.
class SelectableTextTagged extends StatelessWidget {
  /// Creates a [SelectableTextTagged] widget.
  const SelectableTextTagged({super.key, required this.child});

  /// The original [SelectableText] widget.
  final SelectableText child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'test:auto:SelectableText',
      container: true,
      enabled: true,
      child: child,
    );
  }
}

/// Placeholder wrapper for [TextField] widgets prior to code generation.
class TextFieldTagged extends StatelessWidget {
  /// Creates a [TextFieldTagged] widget.
  const TextFieldTagged({super.key, required this.child});

  /// The original [TextField] widget.
  final TextField child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'test:auto:TextField',
      container: true,
      textField: true,
      enabled: true,
      child: child,
    );
  }
}

/// Placeholder wrapper for [TextFormField] widgets prior to code generation.
class TextFormFieldTagged extends StatelessWidget {
  /// Creates a [TextFormFieldTagged] widget.
  const TextFormFieldTagged({super.key, required this.child});

  /// The original [TextFormField] widget.
  final TextFormField child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'test:auto:TextFormField',
      container: true,
      textField: true,
      enabled: true,
      child: child,
    );
  }
}
