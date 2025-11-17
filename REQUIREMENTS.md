
# Codex Prompt for Generating the `flutter_test_tags` Package

This prompt will instruct Codex to generate a **pub.dev-ready Flutter package** named `flutter_test_tags`.  
The package adds **Selenium-friendly test semantics** for Flutter Web by using annotations, code generation, 
and automatic wrapping of input and text widgets.

---

## 🧭 Overview

**Goal:**  
Provide compile-time annotations (`@TestId`, `@AutoTag`) and a code generator that:
- Automatically wraps **all `Text` and `TextField`-like widgets** in `Semantics(label: 'test:...')` by default.  
- Allows developers to **add their own list of widget classes** that should be auto-wrapped (e.g. `ElevatedButton`, `DropdownButton`).
- Generates wrappers and helpers to expose these semantics to the browser DOM for Selenium access.

**Core files to be generated:**

```
flutter_test_tags/
 ├─ lib/flutter_test_tags.dart
 ├─ lib/src/annotations.dart
 ├─ lib/src/runtime.dart
 ├─ lib/src/generator.dart
 ├─ lib/src/builder.dart
 ├─ build.yaml
 ├─ example/
 │   ├─ lib/main.dart
 │   ├─ test_driver/selenium_demo.md
 │   ├─ pubspec.yaml
 │   └─ web/index.html
 ├─ test/
 │   ├─ generator_test.dart
 │   └─ runtime_test.dart
 ├─ README.md
 ├─ LICENSE
 ├─ CHANGELOG.md
 ├─ analysis_options.yaml
 ├─ .github/workflows/ci.yml
 ├─ .gitignore
 └─ pubspec.yaml
```

---

## 🧠 Behavior Details

### 1. Default Wrapping Rules
The generator should automatically wrap:
- `Text`
- `SelectableText`
- `TextField`
- `TextFormField`

These should be wrapped in:

```dart
Semantics(
  label: 'test:auto:<TypeName>',
  container: true,
  child: originalWidget,
);
```

### 2. Customization via Options
Developers can define additional classes to wrap by listing them in a new annotation:

```dart
@AutoWrapWidgets(['ElevatedButton', 'DropdownButton'])
```
or by adding a YAML section in `build.yaml` (optional, advanced use).

The generator must detect those types and create wrapper classes in `.tagged.g.dart` files, similar to `@AutoTag` logic.

### 3. Optional Annotations
Continue supporting:

```dart
@TestId('login-button')
@AutoTag('profile')
```

### 4. Runtime Helper
Provide:

```dart
Widget testTag(
  String id,
  Widget child, {
  bool button = false,
  bool textField = false,
  bool enabled = true,
  bool container = false,
  String prefix = 'test',
})
```

This is used when manual tagging is required.

---

## ⚙️ Generator Logic Summary

1. Detect classes annotated with `@AutoTag` or `@AutoWrapWidgets`.
2. For each such class or for built-in defaults (Text, TextField, etc.):
   - Generate wrapper `<ClassName>Tagged`.
   - Add semantics label `"test:<prefix>:<TypeName>"`.
3. Developers can import the generated `.tagged.g.dart` file or use the global factory `testTag()`.

---

## 📦 Pubspec Metadata

```yaml
name: flutter_test_tags
description: >-
  Compile-time helpers to expose Selenium-friendly ARIA semantics in Flutter Web.
version: 0.2.1
environment:
  sdk: ">=3.7.0 <4.0.0"
  flutter: ">=3.27.0"
dependencies:
  flutter:
    sdk: flutter
  meta: ^1.16.0
dev_dependencies:
  build_runner: ^2.7.1
  source_gen: ^3.0.0
  analyzer: ^7.7.1
  flutter_lints: ^5.0.0
  test: ^1.26.2
topics: [testing, selenium, source-gen, accessibility, web]
```

---

## 🧩 Selenium Integration Example

After starting the app in a browser, your Selenium test should:

```js
// Enable semantics DOM once per page load
const glass = document.querySelector('flt-glass-pane');
if (glass && glass.shadowRoot) {
  const btn = glass.shadowRoot.querySelector('flt-semantics-placeholder');
  if (btn) btn.click();
}

// Then select widgets by role and label
const loginButton = driver.findElement(By.css('[aria-label="test:login-button"]'));
loginButton.click();
```

---

## ✅ Key Quality Requirements

- Strict lint rules (`flutter_lints` + public_member_api_docs)
- All code documented
- Example app fully runnable
- Unit tests for generator and runtime wrappers
- GitHub Actions workflow running:
  - `flutter analyze`
  - `dart test`
  - `pana .` for quality validation

---

## 🚀 Pub.dev Publishing Best Practices

- **Pubspec metadata**: Fill out `description`, `homepage`, `repository`, `issue_tracker`, `documentation`, `topics`, and `funding` (if applicable). Keep `version` in sync with `CHANGELOG.md` and follow semantic versioning.
- **Screenshots & topics**: Provide at least one screenshot or animated GIF in `example/` and reference it in the README; define 2-5 relevant `topics` in `pubspec.yaml`.
- **Lint + format**: Enforce `dart format .`, `flutter analyze`, and `dart analyze` on CI; ensure `analysis_options.yaml` enables `flutter_lints` + `public_member_api_docs`.
- **Testing discipline**: Maintain passing `dart test` and `flutter test`; add coverage-friendly unit tests for generator outputs (golden files in `test/fixtures/`).
- **Documentation quality**: Run `dart doc` locally to confirm public API docs generate without warnings; document all public members.
- **Score readiness**: Run `pana .` before releases and address all actionable suggestions to keep the package score ≥ 120.
- **Dry run before publish**: Execute `flutter pub publish --dry-run` (and save output in CI artifacts) to ensure no blockers.
- **Example app**: Keep `example/` in sync with the package API, ensure it runs on web (`flutter run -d chrome example`), and document Selenium steps in `example/test_driver/`.
- **Continuous delivery**: Tag releases with `v<version>` and let pub.dev's automated publishing (GitHub Actions + OIDC) perform the final `dart pub publish` when that tag is pushed.

---

## 📝 README Requirements

Every release must include an up-to-date `README.md` at the repository root that covers:

1. **Value proposition** – concise summary of what `flutter_test_tags` solves.
2. **Quick start** – add `pubspec.yaml` snippet, installation steps, and minimal usage example with `@TestId`/`testTag`.
3. **Generated wrappers overview** – explain how default auto-wrapping works and how to extend it via annotations or configuration.
4. **Example demo** – link to the `example/` app, include screenshots/GIFs, and describe Selenium integration steps.
5. **Configuration** – document builder options (`build.yaml`), custom widget lists, and relevant CLI commands.
6. **Testing & CI** – list required local commands (`dart format`, `flutter analyze`, `dart test`, `pana .`) and reference GitHub Actions status badge.
7. **Contributing** – outline contribution workflow, code style guardrails, and how to regenerate code (`dart run build_runner build -d`).
8. **License** – cite the chosen license and link to the `LICENSE` file.

README updates should accompany any API change or feature addition, and CI must fail if README checksums (or docs tests) are out of date.

---

## 📄 Licensing Requirements

- Use an [OSI-approved](https://opensource.org/licenses) license. Default to **MIT** unless legal guidance dictates otherwise.
- Store the full license text in `LICENSE` at the repository root. Keep copyright notices current.
- Reference the license in `pubspec.yaml`, `README.md`, and `example/pubspec.yaml`.
- Confirm license compliance for all dependencies and ensure generated code headers do not introduce conflicting terms.

---

## 🧱 Summary of Responsibilities

| Layer | Responsibility |
|-------|----------------|
| `annotations.dart` | Define `@TestId`, `@AutoTag`, `@AutoWrapWidgets`. |
| `generator.dart` | Inspect all widget classes, wrap defaults + configured widgets. |
| `builder.dart` | Register build_runner builder. |
| `runtime.dart` | Implement `testTag()` helper. |
| `example/` | Demonstrate wrapping & Selenium testing. |
| `tests/` | Validate generated output and semantics rendering. |

---

## 🧠 Codex Instruction

Use this document as your single prompt to generate the repository.  
When done, the output must include full file contents for each path (no placeholders).  
Ensure it builds with:

```bash
flutter pub get
dart run build_runner build -d
flutter test
```

---
