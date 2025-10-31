
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
version: 0.2.0
environment:
  sdk: ">=3.5.0 <4.0.0"
  flutter: ">=3.27.0"
dependencies:
  flutter:
    sdk: flutter
  meta: ^1.12.0
dev_dependencies:
  build_runner: ^2.4.0
  source_gen: ^1.5.0
  analyzer: ^6.4.1
  flutter_lints: ^3.0.0
  test: ^1.25.0
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
