import 'package:json_schema/src/json_schema/abstract_json_schema.dart';

abstract class JsonSchemaFactory {
  AbstractJsonSchema newJsonSchema();
}