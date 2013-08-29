#!/usr/bin/env dart

import "package:json_schema/json_schema.dart";
import "package:logging/logging.dart";
import "package:logging_handlers/logging_handlers_shared.dart";

main() {
  Logger.root.onRecord.listen(new PrintHandler());
  Logger.root.level = Level.INFO;

  String url = "http://json-schema.org/draft-04/schema";
  Schema.createSchemaFromUrl(url)
    .then((schema) {
      print('''Does schema validate itself?
${schema.validate(schema.schemaMap)}''');
    });
}
