import '../test_vm/generator_builder_test.dart' as generator_builder_test;
import '../test_vm/generator_config_test.dart' as generator_config_test;
import '../test_vm/generator_hardening_test.dart' as generator_hardening_test;
import '../test_vm/generator_test.dart' as generator_test;

void runVmSuites() {
  generator_config_test.main();
  generator_hardening_test.main();
  generator_test.main();
  generator_builder_test.main();
}
