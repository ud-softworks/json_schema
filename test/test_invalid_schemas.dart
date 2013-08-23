import "dart:io";
import "dart:json" as JSON;
import 'package:unittest/unittest.dart';
import "package:json_schema/json_schema.dart";
import "package:path/path.dart" as path;
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
    new Directory("${here}/invalid_schemas");

  testSuiteFolder.listSync().forEach((testEntry) {
    group("Invalid schema: ${path.basename(testEntry.path)}", () {
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