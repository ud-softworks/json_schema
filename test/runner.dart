import 'utils.dart';
import 'package:unittest/unittest.dart';
import 'test_invalid_schemas.dart' as test_invalid_schemas;
import 'test_validation.dart' as test_validation;

get rootPath => packageRootPath;

void testCore(Configuration config) {
  unittestConfiguration = config;
  main();
}

main() {
  test_invalid_schemas.main();
  test_validation.main();
}

