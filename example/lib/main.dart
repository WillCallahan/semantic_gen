import 'package:flutter/material.dart';
import 'package:semantic_gen/semantic_gen.dart';

void main() {
  runApp(const ExampleApp());
}

/// Demo application showcasing semantic_gen integration.
class ExampleApp extends StatelessWidget {
  /// Creates an [ExampleApp].
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'semantic_gen demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('semantic_gen demo'),
        ),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: LoginForm(),
        ),
      ),
    );
  }
}

/// Login form demonstrating auto-tagged widgets.
@AutoTag('auth')
class LoginForm extends StatelessWidget {
  /// Creates a [LoginForm].
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const <Widget>[
        Text(
          'Sign in to your account',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(labelText: 'Email'),
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        SizedBox(height: 24),
        LoginButton(),
      ],
    );
  }
}

/// Submit button that relies on a manual `testTag` wrapper.
@AutoTag('auth')
class LoginButton extends StatelessWidget {
  /// Creates a [LoginButton].
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return testTag(
      'auth:submit',
      ElevatedButton(
        onPressed: () {
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Signing in...')),
          );
        },
        child: const Text('Sign in'),
      ),
      button: true,
      container: true,
    );
  }
}
