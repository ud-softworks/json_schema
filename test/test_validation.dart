import "dart:io";
import "dart:json" as JSON;
import 'package:unittest/unittest.dart';
import "package:json_schema/json_schema.dart";
import "package:pathos/path.dart" as path;
import "package:logging/logging.dart";
import "package:logging_handlers/logging_handlers_shared.dart";

main() {

  ////////////////////////////////////////////////////////////////////////
  // Uncomment to see logging of excpetions
  //
  // Logger.root.onRecord.listen(new PrintHandler());
  // Logger.root.level = Level.INFO;
  // logFormatExceptions = true;

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
                  //"goo.json",
                  "additionalItems.json",
                  "additionalProperties.json",                  
                  "allOf.json",
                  "anyOf.json",
                  "dependencies.json",
                  "not.json",
                  "oneOf.json",
                  "enum.json",
                  "items.json",
                  "maxItems.json",
                  "maxLength.json",
                  "maxProperties.json",
                  "maximum.json",
                  "minItems.json",
                  "minLength.json",
                  "minProperties.json",
                  "minimum.json",
                  "multipleOf.json",
                  "pattern.json",
                  "patternProperties.json",
                  "properties.json",
                  "required.json",
                  "type.json",
                  "uniqueItems.json",
                  "ref.json",
                  "definitions.json",
                  //"draft04.json",
                  //"refRemote.json",
                ].indexOf(path.basename(testEntry.path)) < 0) return;
        List tests = JSON.parse((testEntry as File).readAsStringSync());
        tests.forEach((testEntry) {
          var schemaData = testEntry["schema"];
          var description = testEntry["description"];
          List validationTests = testEntry["tests"];
          validationTests.forEach((validationTest) {
            String validationDescription = validationTest["description"];
            test("${description} : ${validationDescription}", () {
              var instance = validationTest["data"];
              bool validationResult;
              bool expectedResult = validationTest["valid"];
              var checkResult = expectAsync0(() => expect(validationResult, expectedResult));
              Schema.createSchema(schemaData)
                .then((schema) {
                  validationResult = schema.validate(instance);
                  checkResult();
                });
            });
          });
        });
      });
    }
  });

}