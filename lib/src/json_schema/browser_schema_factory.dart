import 'package:json_schema/json_schema_factory.dart';
import 'package:json_schema/src/json_schema/abstract_json_schema.dart';
import 'package:json_schema/src/json_schema/browser/json_schema.dart';

const BrowserSchemaFactory browserSchemaFactory = const BrowserSchemaFactory();

class BrowserSchemaFactory implements JsonSchemaFactory {
  const BrowserSchemaFactory();

  @override
  AbstractJsonSchema newJsonSchema() => new JsonSchemaBrowser();
}