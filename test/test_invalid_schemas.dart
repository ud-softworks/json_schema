import "dart:io";
import "dart:json" as JSON;
import 'package:unittest/unittest.dart';
import "package:json_schema/json_schema.dart";
import "package:pathos/path.dart" as path;

main() {
  Options options = new Options();
  String here = path.dirname(path.absolute(options.script));
  Directory testSuiteFolder = 
    new Directory("${here}/invalid_schemas");

  testSuiteFolder.listSync().forEach((testEntry) {
    group("Invalid schema: ${testEntry}", () {
      if(testEntry is File) {
        List tests = JSON.parse((testEntry as File).readAsStringSync());
        tests.forEach((testObject) {
          var schemaData = testObject["schema"];
          var description = testObject["description"];
          test(description, () {
            try {
              Schema schema = new Schema.fromMap(schemaData);
              throw "$description: Expected FormatException";
            } on FormatException catch(e) {
              // expected
            }
          });
        });
      }
    });
  });
}