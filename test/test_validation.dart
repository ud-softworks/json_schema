import "dart:io";
import "dart:json" as JSON;
import 'package:unittest/unittest.dart';
import "package:json_schema/json_schema.dart";
import "package:pathos/path.dart" as path;
import "package:logging/logging.dart";
import "package:logging_handlers/logging_handlers_shared.dart";

main() {

  Logger.root.onRecord.listen(new PrintHandler());
  Logger.root.level = Level.FINE;

  ////////////////////////////////////////////////////////////////////////
  // Uncomment to see logging of excpetions
  logFormatExceptions = true;

  Options options = new Options();
  String here = path.dirname(path.absolute(options.script));
  Directory testSuiteFolder = 
    new Directory("${here}/JSON-Schema-Test-Suite/tests/draft4/invalidSchemas");

  testSuiteFolder = 
    new Directory("${here}/JSON-Schema-Test-Suite/tests/draft4");

  testSuiteFolder.listSync().forEach((testEntry) {
    if(testEntry is File) {
      group("Validations ${path.basename(testEntry.path)}", () {
        if(
                [
                  "type.json",
                  "items.json",
                  "additionalItems.json",
                  "minItems.json",
                  "maxItems.json",
                  "minLength.json",
                  "maxLength.json",
                  "pattern.json",
                  "minimum.json",
                  "maximum.json",
                  "multipleOf.json",
                  "minProperties.json",
                  "maxProperties.json",
                  "patternProperties.json",
                  "additionalProperties.json",                  
                  "required.json",
                  "properties.json",
                  "allOf.json",
                  "anyOf.json",
                  "oneOf.json",
                  //"definitions.json",
                ].indexOf(path.basename(testEntry.path)) < 0) return;
        List tests = JSON.parse((testEntry as File).readAsStringSync());
        tests.forEach((testEntry) {
          var schemaData = testEntry["schema"];
          var description = testEntry["description"];
          List validationTests = testEntry["tests"];
          validationTests.forEach((validationTest) {
            String validationDescription = validationTest["description"];
            var instance = validationTest["data"];
            bool expectedResult = validationTest["valid"];
//             print('''
// schema: $schemaData
// descr: $description
// validationDescription: $validationDescription
// instance: $instance
// expectedResult: $expectedResult
// ''');
//            if(expectedResult) return;
            var schema = new Schema.fromMap(schemaData);
            var validator = new Validator(schema);
            bool result = validator.validate(instance);
            test("${description} : ${validationDescription}", () {
              expect(result, expectedResult);
            });
          });
        });
      });
    }
  });

}