// ignore_for_file: unnecessary_library_name

@TestOn('vm')
library vm_suite_test;

import 'package:test/test.dart';

import 'vm_suite_real.dart' if (dart.library.ui) 'vm_suite_stub.dart';

void main() {
  // When running under `dart test`, we execute the real VM suites. In Flutter
  // environments the stubbed implementation keeps mirrors-only code from
  // compiling and simply registers no tests.
  runVmSuites();
}
