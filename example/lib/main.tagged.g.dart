// GENERATED STUB: run `dart run build_runner build -d` inside example/ to regenerate.

part of 'main.dart';

/// Placeholder wrapper for [LoginButton] until code generation runs.
class LoginButtonTagged extends StatelessWidget {
  /// Creates a [LoginButtonTagged] widget.
  const LoginButtonTagged({super.key, required this.child});

  /// The original [LoginButton] widget.
  final LoginButton child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'test:auth:LoginButton',
      container: true,
      button: true,
      enabled: true,
      child: child,
    );
  }
}
