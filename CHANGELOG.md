## Unreleased

- Temporarily pin `source_gen` to the 3.x line to stay compatible with dependent tooling that has not yet adopted 4.x.
- Raise the minimum supported Dart SDK to 3.7 to match the constraints of our build and analyzer tooling.

## 0.2.1

- Renames the package to `semantic_gen`, updates library entry points, and refreshes the example app.
- Re-aligns analyzer/build/test dependencies with the current Flutter stable SDK to keep code generation working.
- Switches the GitHub Actions publish workflow to pub.dev's OIDC-based automated publishing guidance and documents the new flow.

## 0.2.0

- Initial release of `flutter_test_tags`.
- Adds compile-time annotations for Selenium-friendly semantics.
- Provides build runner integration and runtime helpers for manual tagging.
