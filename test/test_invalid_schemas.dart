library test_invalid_schemas;

import 'dart:convert' as convert;
import 'dart:io';
import 'package:json_schema/json_schema.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:unittest/unittest.dart';
// custom <additional imports>
import 'utils.dart';
// end <additional imports>


final _logger = new Logger("test_invalid_schemas");

// custom <library test_invalid_schemas>
// end <library test_invalid_schemas>
main() {
// custom <main>

  String here = packageRootPath;
  Directory testSuiteFolder = new Directory("${here}/test/invalid_schemas");

  testSuiteFolder.listSync().forEach((testEntry) {
    String shortName = path.basename(testEntry.path);
    group("Invalid schema: ${shortName}", () {
      if(testEntry is File) {
        List tests = 
          convert.JSON.decode((testEntry as File).readAsStringSync());
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

// end <main>

}
