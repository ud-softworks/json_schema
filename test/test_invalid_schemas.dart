library json_schema.test_invalid_schemas;

import 'dart:convert' as convert;
import 'dart:io';
import 'package:json_schema/json_schema.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

// custom <additional imports>

// end <additional imports>

final Logger _logger = new Logger('test_invalid_schemas');

// custom <library test_invalid_schemas>
// end <library test_invalid_schemas>

void main([List<String> args]) {
  if (args?.isEmpty ?? false) {
    Logger.root.onRecord.listen(
        (LogRecord r) => print("${r.loggerName} [${r.level}]:\t${r.message}"));
    Logger.root.level = Level.OFF;
  }
// custom <main>

  String here =
      path.dirname(path.dirname(path.absolute(Platform.script.toFilePath())));

  Directory testSuiteFolder = new Directory("${here}/test/invalid_schemas");

  testSuiteFolder.listSync().forEach((testEntry) {
    String shortName = path.basename(testEntry.path);
    group("Invalid schema: ${shortName}", () {
      if (testEntry is File) {
        List tests =
            convert.JSON.decode((testEntry as File).readAsStringSync());
        tests.forEach((testObject) {
          var schemaData = testObject["schema"];
          var description = testObject["description"];
          test(description, () {
            var gotException = (e) {
              _logger.info("Caught expected $e");
              if (!(e is FormatException)) {
                _logger.info('${shortName} wtf it is a ${e.runtimeType}');
              }
              expect(e is FormatException, true);
            };
            var ensureInvalid = expectAsync1(gotException);

            try {
              Schema.createSchema(schemaData).then(ensureInvalid);
            } on FormatException catch (e) {
              ensureInvalid(e);
            } catch (e) {
              ensureInvalid(e);
            }
          });
        });
      }
    });
  });

// end <main>
}
