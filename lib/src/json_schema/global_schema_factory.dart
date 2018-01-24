import 'package:json_schema/json_schema.dart';

/// The globally configured json shema class. Any json schema class that is not
/// explicitly given a [JsonSchema] instance upon construction will
/// inherit this global one.
JsonSchema get globalJsonSchemaFactory => _globalJsonSchemaFactory;
set globalJsonSchema(JsonSchema jsonSchema) {
  if (jsonSchema == null) {
    throw new ArgumentError('json_schema: Global json schema '
        'implementation must not be null.');
  }

  _globalJsonSchemaFactory = jsonSchema;
}

JsonSchema _globalJsonSchemaFactory;

/// Reset the globally configured json schema class.
void resetGlobalTransportPlatform() {
  _globalJsonSchemaFactory = null;
}