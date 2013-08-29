import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import "test_validation.dart" as test_validation;
import "test_invalid_schemas.dart" as test_invalid_schemas;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  test_invalid_schemas.main();
  test_validation.main();
}