import "dart:io";
import "dart:json" as JSON;
import 'package:unittest/unittest.dart';
import "package:json_schema/json_schema.dart";
import "package:path/path.dart" as path;
import "package:logging/logging.dart";
import "package:logging_handlers/logging_handlers_shared.dart";

final _logger = new Logger("test");

main() {

  ////////////////////////////////////////////////////////////////////////
  // Uncomment to see logging
  //
  Logger.root.onRecord.listen(new PrintHandler());
  Logger.root.level = Level.FINE;
  logFormatExceptions = true;

  Options options = new Options();
  String here = path.dirname(path.absolute(options.script));
  Directory testSuiteFolder = 
    new Directory("${here}/invalid_schemas");

  testSuiteFolder.listSync().forEach((testEntry) {
    String shortName = path.basename(testEntry.path);
    group("Invalid schema: ${shortName}", () {
      if(testEntry is File) {
        List tests = JSON.parse((testEntry as File).readAsStringSync());
        tests.forEach((testObject) {
          var schemaData = testObject["schema"];
          var description = testObject["description"];
          test(description, () {
            var gotException = (e) {
              expect(e is FormatException, true);
              _logger.info("Caught expected $e");
            };
            var ensureInvalid = expectAsync1(gotException);

            try {
              Schema.createSchema(schemaData).then(ensureInvalid);
            } on FormatException catch(e) {
              ensureInvalid(e);
            } catch(e) {
              ensureInvalid(e);
            }
          });
        });
      }
    });
  });
}