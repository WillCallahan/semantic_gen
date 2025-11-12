# semantic_gen

[![CI](https://github.com/WillCallahan/semantic_gen/actions/workflows/ci.yml/badge.svg)](https://github.com/WillCallahan/semantic_gen/actions/workflows/ci.yml)
[![Publish](https://github.com/WillCallahan/semantic_gen/actions/workflows/publish.yml/badge.svg)](https://github.com/WillCallahan/semantic_gen/actions/workflows/publish.yml)
[![Pub](https://img.shields.io/pub/v/semantic_gen.svg)](https://pub.dev/packages/semantic_gen)
[![License: MIT](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

`semantic_gen` generates deterministic semantics wrappers for Flutter widgets so Selenium and other DOM-driven tools can discover them by stable labels. Annotate the widgets you care about (or configure the generator globally) and let build_runner create the wrappers at compile time.

---

## 🚀 Quick Start

1. Add the dependency to your Flutter package:

   ```yaml
   dependencies:
     semantic_gen: ^0.2.1

   dev_dependencies:
     build_runner: ^2.4.0
   ```

2. (Optional) Drop a `semantic_gen.yaml` next to your `pubspec.yaml` to tweak behaviour:

   ```yaml
   enabled: true        # flip to false to turn the generator off
   prefix: test
   auto_wrap_widgets:
     - ElevatedButton
   ```

3. Create a library with a `part` directive, opt into wrapping, then trigger code
   generation:

   ```bash
   flutter pub get
   dart run build_runner build -d
   ```

```dart
import 'package:semantic_gen/semantic_gen.dart';

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

## 🧩 Configuration

`semantic_gen` reads options from `build.yaml` first, then from an optional `semantic_gen.yaml` file that lives next to your `pubspec.yaml`. If neither provides a value, sensible defaults are used.

- `enabled` (bool): set to `false` to disable wrapper generation without touching your source code.
- `prefix` (string): customise the leading segment of every generated semantics label (defaults to `test`).
- `auto_wrap_widgets` (list of strings): additional widget class names that should always receive wrappers.

To relocate the config file, specify `config_path` in `build.yaml`:

```yaml
targets:
  $default:
    builders:
      semantic_gen:auto_tag_builder:
        options:
          config_path: tool/semantic_gen.yaml
        generate_for:
          - lib/**.dart
```

You can also enforce options directly in `build.yaml` (overriding anything in `semantic_gen.yaml`):

```yaml
targets:
  $default:
    builders:
      semantic_gen:auto_tag_builder:
        options:
          enabled: false
          prefix: qa
          auto_wrap_widgets:
            - ElevatedButton
            - FilledButton
```

### Environment-specific toggles

Because code generation happens during the `build_runner` step (before your app runs), `--dart-define` values are not visible to `semantic_gen`. To turn the generator on only for select build pipelines, drive it via configuration files and `build_runner` overrides instead:

1. Keep generation disabled by default in `semantic_gen.yaml`:

   ```yaml
   enabled: false
   ```

2. Create an environment-specific override (for example `semantic_gen.staging.yaml`) that flips the flag and tweaks any other options you need:

   ```yaml
   enabled: true
   prefix: staging
   ```

3. In your staging build script, run:

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs \
     --define semantic_gen:auto_tag_builder=config_path=semantic_gen.staging.yaml
   ```

Production builds can omit the `--define` (or point it at a different file), keeping wrappers disabled. This approach ensures only the desired environments emit the generated semantics wrappers.

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

## 🛠️ Developer Workflow

| Task | How |
|------|-----|
| Format | `dart format .` |
| Analyze | `flutter analyze && dart analyze` |
| Generate code | `dart run build_runner build -d` |
| Run tests | `dart test && flutter test test/runtime_test.dart` |
| Quality gate | `pana .` |
| Toggle semantics | `semantic_gen.yaml: enabled: false` (or override in `build.yaml`) |

Update `semantic_gen.yaml` or the builder options in `build.yaml` whenever you need to change prefixes, toggle coverage, or temporarily disable generation.

---

## 💡 Contributing

1. Fork and clone the repository.
2. Install dependencies: `flutter pub get`.
3. Make changes, keeping lint warnings at zero (`flutter analyze`).
4. Regenerate code and tests as needed.
5. Update `README.md`, `CHANGELOG.md`, and docs when APIs change.
6. Run the full test suite (`dart test test/vm` and `flutter test test/runtime_test.dart`) and ensure `pana .` reports no actionable issues.

Submit a PR with a descriptive title, linked issue (if applicable), and screenshots or logs for visual changes.

---

## 📦 Release Checklist

- Update `pubspec.yaml` version and keep `CHANGELOG.md` in sync.
- Verify documentation: `dart doc` and README sections.
- Refresh screenshots/GIFs referenced in the README.
- Run `dart format`, `flutter analyze`, `dart test test/vm`, `flutter test test/runtime_test.dart`, and `pana .`.
- Execute `flutter pub publish --dry-run` and record the output in CI artifacts.
- Tag the release (`git tag v<version>`) before publishing.
- Push the release tag (`v<version>`) to trigger the automated Publish workflow configured via pub.dev's OIDC integration (no stored secrets required).

---

## 📜 License

Released under the MIT License. See `LICENSE` for details.
