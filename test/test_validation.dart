import "dart:io";
import "dart:json" as JSON;
import 'package:unittest/unittest.dart';
import "package:json_schema/json_schema.dart";
import "package:pathos/path.dart" as path;

main() {
  Options options = new Options();
  String here = path.dirname(path.absolute(options.script));
  Directory testSuiteFolder = 
    new Directory("${here}/JSON-Schema-Test-Suite/tests/draft4/invalidSchemas");

  testSuiteFolder = 
    new Directory("${here}/JSON-Schema-Test-Suite/tests/draft4");

  testSuiteFolder.listSync().forEach((testEntry) {
    if(testEntry is File) {
      List tests = JSON.parse((testEntry as File).readAsStringSync());
      tests.forEach((test) {
        var schemaData = test["schema"];
        var description = test["description"];
        List validationTests = test["tests"];
        validationTests.forEach((validationTest) {
          String validationDescription = validationTest["description"];
          var instance = validationTest["data"];
          bool expectedResult = validationTest["valid"];
          print('''
schema: $schemaData
descr: $description
validationDescription: $validationDescription
instance: $instance
expectedResult: $expectedResult
''');
          Schema schema = new Schema.fromMap(schemaData);
        });
      });
    }
  });

}