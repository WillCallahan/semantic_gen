import 'package:flutter/widgets.dart';

/// Wraps [child] in a [Semantics] widget that exposes a deterministic
/// accessibility label for end-to-end tests.
Widget testTag(
  String id,
  Widget child, {
  bool button = false,
  bool textField = false,
  bool enabled = true,
  bool container = false,
  String prefix = 'test',
}) {
  return Semantics(
    label: '$prefix:$id',
    button: button,
    textField: textField,
    enabled: enabled,
    container: container,
    child: child,
  );
}
