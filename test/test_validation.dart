library json_schema.test_validation;

import 'dart:convert' as convert;
import 'dart:io';
import 'package:json_schema/json_schema.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

// custom <additional imports>
// end <additional imports>

final _logger = new Logger('test_validation');

// custom <library test_validation>
// end <library test_validation>

main([List<String> args]) {
  Logger.root.onRecord.listen((LogRecord r) =>
      print("${r.loggerName} [${r.level}]:\t${r.message}"));
  Logger.root.level = Level.OFF;
// custom <main>

  ////////////////////////////////////////////////////////////////////////
  // Uncomment to see logging of excpetions
  // Logger.root.onRecord.listen((LogRecord r) =>
  //   print("${r.loggerName} [${r.level}]:\t${r.message}"));

  Logger.root.level = Level.OFF;

  String here = path.dirname(
    path.dirname(
        path.absolute(Platform.script.toFilePath())));

  Directory testSuiteFolder =
    new Directory("${here}/test/JSON-Schema-Test-Suite/tests/draft4/invalidSchemas");

  testSuiteFolder =
    new Directory("${here}/test/JSON-Schema-Test-Suite/tests/draft4");

  var optionals =
    new Directory(path.joinAll([testSuiteFolder.path, 'optional']));

  var all = testSuiteFolder.listSync()..addAll(optionals.listSync());

  all.forEach((testEntry) {
    if(testEntry is File) {
      group("Validations ${path.basename(testEntry.path)}", () {

        // TODO: add these back or get replacements
        // Skip these for now - reason shown
        if([
          'refRemote.json', // seems to require webserver running to vend files
        ].contains(path.basename(testEntry.path))) return;


        List tests = convert.JSON.decode((testEntry as File).readAsStringSync());
        tests.forEach((testEntry) {
          var schemaData = testEntry["schema"];
          var description = testEntry["description"];
          List validationTests = testEntry["tests"];

          if(description == 'remote ref, containing refs itself') {
            print('''WARNING: Skipping failing test: $description

This test fails on drone.io with:

Validations ref.json remote ref, containing refs itself : remote ref valid
  RedirectException: Redirect loop detected
  dart:io                                                 _HttpClient.getUrl
  package:json_schema/src/json_schema/schema.dart 68:31   Schema.createSchemaFromUrl
  package:json_schema/src/json_schema/schema.dart 376:31  Schema._getRef
  package:json_schema/src/json_schema/schema.dart 448:27  Schema._accessMap.<fn>
  package:json_schema/src/json_schema/schema.dart 465:17  Schema._validateSchema.<fn>
  dart:collection                                         _CompactLinkedHashMap.forEach
  package:json_schema/src/json_schema/schema.dart 462:16  Schema._validateSchema
  package:json_schema/src/json_schema/schema.dart 507:5   Schema._initialize
  package:json_schema/src/json_schema/schema.dart 17:5    Schema.Schema._fromRootMap
  package:json_schema/src/json_schema/schema.dart 97:9    Schema.createSchema
  test/test_validation.dart 69:22                         main.<fn>.<fn>.<fn>.<fn>.<fn>
''');
          }

          validationTests.forEach((validationTest) {
            String validationDescription = validationTest["description"];
            test("${description} : ${validationDescription}", () {
              var instance = validationTest["data"];
              bool validationResult;
              bool expectedResult = validationTest["valid"];
              var checkResult = expectAsync(() => expect(validationResult, expectedResult));
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

  test("Schema self validation", () {
    // Pull in the official schema, verify description and then ensure
    // that the schema satisfies the schema for schemas
    String url = "http://json-schema.org/draft-04/schema";
    Schema.createSchemaFromUrl(url)
      .then((schema) {
          expect(schema.schemaMap["description"], "Core schema meta-schema");
          expect(schema.validate(schema.schemaMap), true);
      });
  });

// end <main>


}
