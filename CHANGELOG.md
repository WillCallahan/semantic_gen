## 0.2.3

- **BREAKING**: The generator now overwrites source files to automatically wrap widgets with `Semantics`.
- The old `.tagged.g.dart` files are no longer generated.
- The build process now creates temporary `.semgen.dart` files which are used to generate the final output.
- Refactored the internal APIs to separate widget collection from code generation.
- Fixed all analyzer issues.

## 0.2.2

- Temporarily pin `source_gen` to the 3.x line to stay compatible with dependent tooling that has not yet adopted 4.x.
- Raise the minimum supported Dart SDK to 3.7 to match the constraints of our build and analyzer tooling.
- Renames the package to `semantic_gen` and updates library entry points and examples.
- Automatically wraps common tap targets (e.g. `GestureDetector`, `InkWell`, Material buttons, and `ListTile` variants) so tap-able widgets receive deterministic semantics without extra configuration.

## 0.2.1

- Renames the package to `semantic_gen`, updates library entry points, and refreshes the example app.
- Re-aligns analyzer/build/test dependencies with the current Flutter stable SDK to keep code generation working.
- Switches the GitHub Actions publish workflow to pub.dev's OIDC-based automated publishing guidance and documents the new flow.

## 0.2.0

- Initial release of `flutter_test_tags`.
- Adds compile-time annotations for Selenium-friendly semantics.
- Provides build runner integration and runtime helpers for manual tagging.