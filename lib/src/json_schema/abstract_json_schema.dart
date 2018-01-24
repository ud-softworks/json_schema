import 'dart:async';

import 'package:json_schema/src/json_schema/schema_type.dart';

abstract class AbstractJsonSchema {
  AbstractJsonSchema get root;
  Map get schemaMap;
  String get path;
  num get multipleOf;
  num get maximum;
  num get minimum;
  int get maxLength;
  int get minLength;
  RegExp get pattern;
  List get enumValues;
  List<AbstractJsonSchema> get allOf;
  List<AbstractJsonSchema> get anyOf;
  List<AbstractJsonSchema> get oneOf;
  AbstractJsonSchema get notSchema;
  Map<String, AbstractJsonSchema> get definitions;
  Uri get id;
  String get ref;
  String get description;
  String get title;
  List<SchemaType> get schemaTypeList;

  /// To match all items to a schema
  AbstractJsonSchema get items;

  /// To match each item in array to a schema
  List<AbstractJsonSchema> get itemsList;
  dynamic get additionalItems;
  int get maxItems;
  int get minItems;
  bool get uniqueItems;
  List<String> get requiredProperties;
  int get maxProperties;
  int get minProperties;
  Map<String, AbstractJsonSchema> get properties;
  bool get additionalProperties;
  AbstractJsonSchema get additionalPropertiesSchema;
  Map<RegExp, AbstractJsonSchema> get patternProperties;
  Map<String, AbstractJsonSchema> get schemaDependencies;
  Map<String, List<String>> get propertyDependencies;
  dynamic get defaultValue;

  /// Map of path to schema object
  Map<String, AbstractJsonSchema> get refMap;


  // STATIC??
  Future<AbstractJsonSchema> createSchemaFromUrl(String schemaUrl);
  Future<AbstractJsonSchema> createSchema(Map data);

  /// Validate [instance] against this schema
  bool validate(dynamic instance);
  bool get exclusiveMaximum;
  bool get exclusiveMinimum;
  bool propertyRequired(String property);

  /// Given path, follow all references to an end path pointing to schema
  String endPath(String path);

  /// Returns paths of all paths
  Set get paths;

  /// Method to find schema from path
  AbstractJsonSchema resolvePath(String path);
}