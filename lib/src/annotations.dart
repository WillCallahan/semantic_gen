/// An annotation used to assign a deterministic semantics label to a widget.
///
/// When combined with [AutoTag], the generator emits wrappers that surface the
/// given [value] as part of the generated semantics label (e.g.
/// `test:login-button`).
class TestId {
  /// Creates a [TestId] annotation.
  const TestId(this.value);

  /// The semantics identifier applied to a widget.
  final String value;
}

/// Requests that the generator create semantics wrappers for a widget class.
///
/// The optional [namespace] lets you replace the default `auto` namespace that
/// appears in labels such as `test:auto:LoginButton`.
class AutoTag {
  /// Creates an [AutoTag] annotation.
  const AutoTag([this.namespace, this.custom]);

  /// Optional namespace inserted between the prefix and the class name in the
  /// generated semantics label.
  final String? namespace;

  /// Optional custom wrapper to apply to the widget.
  final WrapperTemplate? custom;
}

/// Declares additional widget types that should receive automatically generated
/// wrappers within the annotated library.
///
/// Apply this at the library level:
///
/// ```dart
/// @AutoWrapWidgets(['ElevatedButton', 'DropdownButton'])
/// library my_library;
/// ```
class AutoWrapWidgets {
  /// Creates an [AutoWrapWidgets] annotation.
  const AutoWrapWidgets(this.widgetTypes, [this.custom]);

  /// Names of widget classes that should be wrapped.
  final List<String> widgetTypes;

  /// Optional custom wrapper to apply to the widget.
  final WrapperTemplate? custom;
}

/// A wrapper template to apply to a widget.
///
/// The template must contain the `{{child}}` placeholder, which will be
/// replaced with the original widget.
///
/// Example:
/// ```dart
/// @AutoTag(custom: WrapperTemplate('MyWrapper(child: {{child}})')
/// class MyWidget extends StatelessWidget { ... }
/// ```
class WrapperTemplate {
  /// Creates a [WrapperTemplate] annotation.
  const WrapperTemplate(this.template);

  /// The wrapper template.
  final String template;
}
