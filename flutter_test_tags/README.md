# flutter_test_tags

`flutter_test_tags` delivers Selenium-friendly semantics for Flutter Web by wrapping widgets with predictable accessibility labels at build time. Use annotations or configuration to opt in, and let the code generator produce the glue that Selenium (or any DOM-driven test harness) needs.

---

## 🚀 Quick Start

Add the dependency to your Flutter package:

```yaml
dependencies:
  flutter_test_tags: ^0.2.0

dev_dependencies:
  build_runner: ^2.4.0
```

Create a library with a `part` directive, opt into wrapping, then trigger code
generation:

```bash
flutter pub get
dart run build_runner build -d
```

```dart
import 'package:flutter_test_tags/flutter_test_tags.dart';

part 'home.tagged.g.dart';

@AutoWrapWidgets(['ElevatedButton'])
library home;

@AutoTag('login')
class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) => const Text('Sign in');
}
```

The generator produces wrappers such as `LoginButtonTagged` and `TextTagged`
that expose labels like `test:login:LoginButton`, making them Selenium-friendly.

---

## 🔖 Generated Wrappers & Annotations

- **Default coverage**: `Text`, `SelectableText`, `TextField`, and `TextFormField` are auto-wrapped with `Semantics(label: 'test:auto:<TypeName>')`.
- **Custom classes**: Annotate widgets with `@AutoWrapWidgets(['ElevatedButton'])` or use `build.yaml` to list additional types.
- **Explicit IDs**: Apply `@TestId('login-button')` or `testTag('checkout-button', child)` when you need deterministic identifiers.
- **Runtime helper**: `testTag()` exposes convenience parameters to mark buttons, text fields, and other semantics roles.

Refer to the API docs (`dart doc`) for full annotation behavior and generator options.

---

## 🧪 Example & Selenium Integration

The `example/` app shows auto-tagging, manual tagging, and Selenium wiring. Launch it with:

```bash
flutter run -d chrome example
```

In Selenium, enable semantics DOM once per load and query by ARIA label:

```js
const loginButton = driver.findElement(By.css('[aria-label="test:login-button"]'));
loginButton.click();
```

`example/test_driver/selenium_demo.md` documents the end-to-end setup, including enabling the Flutter semantics tree.

---

## ⚙️ Configuration Cheatsheet

| Task | Command |
|------|---------|
| Format | `dart format .` |
| Analyze | `flutter analyze && dart analyze` |
| Generate code | `dart run build_runner build -d` |
| Run tests | `dart test test/generator_test.dart && flutter test test/runtime_test.dart` |
| Quality gate | `pana .` |

Customize the generator by editing `build.yaml`, adding `auto_wrap_widgets`, and re-running `build_runner`.

---

## 💡 Contributing

1. Fork and clone the repository.
2. Install dependencies: `flutter pub get`.
3. Make changes, keeping lint warnings at zero (`flutter analyze`).
4. Regenerate code and tests as needed.
5. Update `README.md`, `CHANGELOG.md`, and docs when APIs change.
6. Run the full test suite (`dart test test/generator_test.dart` and `flutter test test/runtime_test.dart`) and ensure `pana .` reports no actionable issues.

Submit a PR with a descriptive title, linked issue (if applicable), and screenshots or logs for visual changes.

---

## 📦 Release Checklist

- Update `pubspec.yaml` version and keep `CHANGELOG.md` in sync.
- Verify documentation: `dart doc` and README sections.
- Refresh screenshots/GIFs referenced in the README.
- Run `dart format`, `flutter analyze`, `dart test test/generator_test.dart`, `flutter test test/runtime_test.dart`, and `pana .`.
- Execute `flutter pub publish --dry-run` and record the output in CI artifacts.
- Tag the release (`git tag v<version>`) before publishing.
- Trigger the `Publish` GitHub Action with the new tag once checks pass (requires `PUB_CREDENTIALS` secret).

---

## 📜 License

Released under the MIT License. See `LICENSE` for details.
