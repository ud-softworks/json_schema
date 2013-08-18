/// Support for validating json instances against a json schema
library json_schema;

import "dart:io";
import "dart:json" as JSON;
import "package:plus/pprint.dart";

class SchemaType {
  static const ARRAY = const SchemaType._(0);
  static const BOOLEAN = const SchemaType._(1);
  static const INTEGER = const SchemaType._(2);
  static const NUMBER = const SchemaType._(3);
  static const NULL = const SchemaType._(4);
  static const OBJECT = const SchemaType._(5);
  static const STRING = const SchemaType._(6);

  static get values => [
    ARRAY,
    BOOLEAN,
    INTEGER,
    NUMBER,
    NULL,
    OBJECT,
    STRING
  ];

  final int value;

  const SchemaType._(this.value);

  String toString() {
    switch(this) {
      case ARRAY: return "array";
      case BOOLEAN: return "boolean";
      case INTEGER: return "integer";
      case NUMBER: return "number";
      case NULL: return "null";
      case OBJECT: return "object";
      case STRING: return "string";
    }
  }

  static SchemaType fromString(String s) {
    switch(s) {
      case "array": return ARRAY;
      case "boolean": return BOOLEAN;
      case "integer": return INTEGER;
      case "number": return NUMBER;
      case "null": return NULL;
      case "object": return OBJECT;
      case "string": return STRING;
    }
  }


  // custom <enum SchemaType>
  // end <enum SchemaType>

}

/// Exception indicating the schema is not conformant
class InvalidSchema implements Exception {

  // custom <class InvalidSchema>
  // end <class InvalidSchema>
}

abstract class ISchema {

  // custom <class ISchema>

  bool validate(dynamic jsonData);

  // end <class ISchema>
}

class NumericSchema implements ISchema {

  // custom <class NumericSchema>
  // end <class NumericSchema>
}

class StringSchema implements ISchema {

  // custom <class StringSchema>
  // end <class StringSchema>
}

class ArraySchema implements ISchema {

  // custom <class ArraySchema>
  // end <class ArraySchema>
}

class ObjectSchema implements ISchema {

  // custom <class ObjectSchema>
  // end <class ObjectSchema>
}

/// Constructed with a json schema, either as string or Map
class Schema implements ISchema {
  Schema.fromString(
    this._schemaText,
    [
      this._path = '#'
    ]
  ) {
    // custom <Schema.fromString>
    _schemaMap = JSON.parse(_schemaText);
    _initialize();
    // end <Schema.fromString>
  }
  
  Schema.fromMap(
    this._schemaMap,
    [
      this._path = '#'
    ]
  ) {
    // custom <Schema.fromMap>
    _initialize();
    // end <Schema.fromMap>
  }
  
  /// Text defining the schema for validation
  String _schemaText;
  Map _schemaMap = {};
  String _path;
  String _id;
  String _description;
  SchemaType _schemaType;
  Map<String,Schema> _propertySchemas = {};
  List<Schema> _allOf;
  List<Schema> _anyOf;
  List<Schema> _oneOf;
  Schema _itemSchema;
  List<String> _requiredProperties;
  dynamic _defaultValue;
  num _multipleOf;
  num _maximum;
  bool _exclusiveMaximum;
  num _minimum;
  bool _exclusiveMinimum;

  // custom <class Schema>

  bool get isNumeric => _schemaType == SchemaType.NUMBER ||
    _schemaType == SchemaType.INTEGER;

  void _initializeNumericValidation() {
    print("Initializing numeric validation on $_id");
    
  }

  void _initialize() {
    _schemaType = SchemaType.fromString(_schemaMap["type"]);
    _id = _schemaMap["id"];
    _description = _schemaMap["description"];

    if(isNumeric)
      _initializeNumericValidation();

    var mapEntry;
    if((mapEntry =_schemaMap["properties"]) != null) {
      mapEntry.forEach((property, subSchema) {
        _propertySchemas[property] =
          new Schema.fromMap(subSchema, "$_path/properties/$property");
      });
    }

    if((mapEntry = _schemaMap["items"]) != null)
      _itemSchema = new Schema.fromMap(mapEntry, "$_path/items");

    if((mapEntry = _schemaMap["required"]) != null)
      _requiredProperties = new List.from(mapEntry);

    if((mapEntry = _schemaMap["allOf"]) != null)
      _allOf = new List<Schema>.from(
        mapEntry.map((schema) =>
            new Schema.fromMap(schema, "$_path/allOf")));

    if((mapEntry = _schemaMap["anyOf"]) != null)
      _anyOf = new List<Schema>.from(
        mapEntry.map((schema) =>
            new Schema.fromMap(schema, "$_path/anyOf")));

    if((mapEntry = _schemaMap["oneOf"]) != null)
      _oneOf = new List<Schema>.from(
        mapEntry.map((schema) =>
            new Schema.fromMap(schema, "$_path/oneOf")));

    if((mapEntry = _schemaMap["default"]) != null)
      _defaultValue = mapEntry;
  }

  String toString() =>
    '''
path: $_path
id: $_id
description: $_description
type: $_schemaType
properties: $_propertySchemas
allOf: $_allOf
anylOf: $_anyOf
oneOf: $_oneOf
itemSchema: $_itemSchema
required: $_requiredProperties
''';

  // end <class Schema>
}

/// Initialized with schema and will validate json instances against it
class Validator {
  Validator(
    this._schema
  ) {

  }
  
  Schema _schema;

  // custom <class Validator>

  bool validate(Map jsonInstance) {
    print("Validating: $jsonInstance");
    return false;
  }

  bool validateJsonString(String jsonInstance) {
    return validate(JSON.parse(jsonInstance));
  }

  // end <class Validator>
}

// custom <library json_schema>

ISchema createSchema(Map schema, [ String path ]) {
  SchemaType schemaType = SchemaType.fromString(_schemaMap["type"]);
  
}

// end <library json_schema>

