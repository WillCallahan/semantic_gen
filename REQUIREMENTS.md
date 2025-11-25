# Project: semantic_gen

**Purpose:** A code-generation tool for creating widget wrappers in Flutter.

## Overview

`semantic_gen` is a Dart code generation tool that simplifies the process of wrapping existing Flutter widgets with other widgets. Its primary and original purpose is to enhance testability, particularly for Flutter Web applications, by injecting `Semantics` widgets that are detectable by testing frameworks like Selenium.

However, the tool has been extended to support more generic, Aspect-Oriented Programming (AOP) like behavior. Users can define their own custom wrapper widgets, allowing them to inject cross-cutting concerns (e.g., logging, styling, feature flagging) around their existing UI components.

**This is NOT a true AOP framework.** It does not perform "in-place" code modification. Instead, it generates new widget classes (e.g., `TextTagged` for `Text`) that you must manually use in your code instead of the original widget.

For true AOP in Dart and Flutter, which involves modifying code at build time without manual intervention, consider using a dedicated framework like [aspectd](https://github.com/XianyuTech/aspectd).

## Features

### 1. Testability Wrappers (Default Behavior)

By default, `semantic_gen` is configured to help with testing. It can be configured to automatically generate versions of common widgets (like `Text`, `TextField`, `ElevatedButton`, etc.) that are wrapped in a `Semantics` widget. This makes it easy to find and interact with these widgets in a web browser during integration tests.

**Example:**

If you have `Text('Hello')` in your code, you can use the generated `TextTagged('Hello')` widget, which will render with accessibility metadata that your test runner can use.

### 2. Custom Wrapper Generation (AOP-like feature)

`semantic_gen` also allows you to define your own custom wrapper templates. This is a powerful feature that lets you create your own AOP-like aspects.

You can create a custom annotation and use it to specify a wrapper template. The generator will then create a new widget that wraps the target widget with your custom template.

**Example: Creating a Logging Aspect**

You could define a `@LogOnTap` annotation that wraps a widget with a `GestureDetector` to log taps.

```dart
// 1. Define your wrapper template
@WrapperTemplate('GestureDetector(onTap: () => print("Tapped!"), child: {{child}})')

// 2. Apply it to a widget
@LogOnTap()
class MyButton extends StatelessWidget { ... }
```

Running the generator would produce a `MyButtonTagged` widget that includes the `GestureDetector`.

## How it Works

`semantic_gen` uses the `build_runner` and `source_gen` packages to scan your code for annotations.

1.  **Annotations:** You annotate your widget classes or a configuration file with annotations like `@AutoWrapWidgets` or your own custom wrapper annotations.
2.  **Code Generation:** During the build process (`dart run build_runner build`), the generator reads these annotations and creates a new `.g.dart` file. This file contains the new, wrapped versions of your widgets.
3.  **Manual Usage:** You then import the generated file and use the new widget classes in your application code.

## Getting Started

1.  **Add dependencies:** Add `semantic_gen` to your `pubspec.yaml`.
2.  **Configure `build.yaml`:** Set up the builder for `semantic_gen`.
3.  **Annotate your code:** Add annotations to specify which widgets to wrap and how.
4.  **Run the builder:** Execute `dart run build_runner build`.
5.  **Use the generated code:** Import the `.g.dart` file and use your new widgets.

For detailed setup and usage, please refer to the `README.md` file and the `example/` directory.