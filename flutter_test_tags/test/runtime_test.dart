import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test_tags/flutter_test_tags.dart';

void main() {
  testWidgets('testTag wraps child with semantics metadata', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: testTag(
            'login-button',
            const Text('Login'),
            button: true,
            container: true,
          ),
        ),
      ),
    );

    final semanticsWidget = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'test:login-button',
      ),
    );

    expect(semanticsWidget.properties.button, isTrue);
    expect(semanticsWidget.properties.label, 'test:login-button');
  });
}
