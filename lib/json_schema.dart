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

/// Constructed with a json schema, either as string or Map
class Schema {
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
  num _multipleOf;
  num _maximum;
  bool _exclusiveMaximum;
  num _minimum;
  bool _exclusiveMinimum;
  int _maxLength;
  int _minLength;
  RegExp _pattern;
  String _id;
  String _description;
  SchemaType _schemaType;
  List<SchemaType> _schemaTypeList;
  Map<String,Schema> _propertySchemas = {};
  List<Schema> _allOf;
  List<Schema> _anyOf;
  List<Schema> _oneOf;
  Schema _items;
  List<Schema> _itemsList;
  dynamic _additionalItems;
  int _maxItems;
  int _minItems;
  bool _uniqueItems = false;
  List<String> _requiredProperties;
  int _maxProperties;
  int _minProperties;
  dynamic _defaultValue;

  // custom <class Schema>

  void checkRef() {}
  void checkAdditionalItems() {}
  void checkAdditionalProperties() {}
  void checkAllOf() {}
  void checkAnyOf() {}
  void checkDependencies() {}
  void checkEnum() {}
  void checkFormat() {}
  void checkitems() {}
  void checkMaxItems() {}
  void checkMaxLength() {}
  void checkMaxProperties() {}
  void checkMaximum() {}
  void checkMinItems() {}
  void checkMinLength() {}
  void checkMinProperties() {}
  void checkMinimum() {}
  void checkMultipleOf() {}
  void checkNot() {}
  void checkOneOf() {}
  void checkPattern() {}
  void checkPatternProperties() {}
  void checkProperties() {}
  void checkRequired() {}
  void checkType() {}
  void checkUniqueItems() {}


  bool get isNumeric => _schemaType == SchemaType.NUMBER ||
    _schemaType == SchemaType.INTEGER;

  void _initializeNumericValidation() {
    print("Initializing numeric validation on $_id");
    
  }

  int _requirePositiveNumeric(String key, dynamic value) {
    if((value is num) || (value is int)) {
      if(value <= 0) {
        throw new
          FormatException("$_path: '$key' must be greater than 0");
      }
    } else {
      throw new
        FormatException("$_path: '$key' must be a number");
    }
  }

  dynamic _requirePositive(String key, dynamic value) {
    if(value <= 0)
      throw new
        FormatException("$_path: '$key' must be positive");
    return value;
  }

  int _requirePositiveInt(String key, dynamic value) {
    if(value is int) 
      return _requirePositive(key, value);

    throw new
      FormatException("$_path: '$key' must be an int");
  }

  dynamic _requireNonNegative(String key, dynamic value) {
    if(value < 0)
      throw new
        FormatException("$_path: '$key' must be non-negative");
    return value;
  }

  int _requireNonNegativeInt(String key, dynamic value) {
    if(value is int)
      return _requireNonNegative(key, value);

    throw new
      FormatException("$_path: '$key' must be an int");
  }

  _getType(dynamic value) {
    if(value is String) {
      _schemaType = SchemaType.fromString(value);
    } else if(value is List) {
      _schemaTypeList = value.map((v) => 
          SchemaType.fromString(v)).toList();
    } else {
      throw new 
        FormatException("$_path: 'type' must be 'string' or 'array'");
    }
  }
  _getMultipleOf(dynamic value) {
    if((value is num) || (value is int)) {
      if(value <= 0) {
        throw new
          FormatException("$_path: 'multipleOf' must be greater than 0");
      }
      _multipleOf = value;
    } else {
      throw new
        FormatException("$_path: 'multipleOf' must be a number");
    }
  }
  _getMaximum(dynamic value) {
    if((value is num) || (value is int)) {
      _maximum = value;
    } else {
      throw new
        FormatException("$_path: 'maximum' must be a number");
    }
  }
  _getExclusiveMaximum(dynamic value) {
    if(value is bool) {
      _exclusiveMaximum = value;
    } else {
      throw new
        FormatException("$_path: 'exclusiveMaximum' must be a boolean");
    }
  }
  _getMinimum(dynamic value) {
    if((value is num) || (value is int)) {
      _minimum = value;
    } else {
      throw new
        FormatException("$_path: 'minimum' must be a number");
    }
  }
  _getExclusiveMinimum(dynamic value) {
    if(value is bool) {
      _exclusiveMinimum = value;
    } else {
      throw new
        FormatException("$_path: 'exclusiveMinimum' must be a boolean");
    }
  }
  _getMaxLength(dynamic value) =>
    _maxLength = _requireNonNegativeInt('maxLength', value);
  _getMinLength(dynamic value) =>
    _minLength = _requireNonNegativeInt('minLength', value);
  _getPattern(dynamic value) {
    if(value is String) {
      _pattern = new RegExp(value);
    } else {
      throw new
        FormatException("$_path: 'pattern' must be a string");
    }
  }
  _getId(String value) => _id = value;
  _getDescription(String value) => _description = value;
  _getPropertySchemas(Map value) =>
    value.forEach((property, subSchema) {
      _propertySchemas[property] =
        new Schema.fromMap(subSchema, "$_path/properties/$property");
    });
  _getItems(dynamic value) {
    if(value is Map) {
      _items = new Schema.fromMap(value, "$_path/items");
    } else if(value is List) {
      int index = 0;
      _itemsList = value.map((item) => 
          new Schema.fromMap(item, "$_path/items/${index++}")).toList();
    } else {
      throw new
        FormatException("$_path: 'items' must be 'object' or 'array'");
    }
  }
  _getAdditionalItems(dynamic value) {
    if(value is bool) {
      _additionalItems = value;
    } else if(value is Map) {
      _additionalItems = new Schema.fromMap(value, "$_path/additionalItems");
    } else {
      throw new
        FormatException("$_path: 'additionalItems' must be 'bool' or 'object'");
    }
  }
  _getMaxItems(dynamic value) =>
    _maxItems = _requireNonNegativeInt('maxItems', value);
  _getMinItems(dynamic value) =>
    _minItems = _requireNonNegativeInt('minItems', value);
  _getUniqueItems(dynamic value) {
    if(value is bool) {
      _uniqueItems = value;
    } else {
      throw new
        FormatException("$_path: 'uniqueItems' must be 'bool'");
    }
  }
  _getRequired(List value) =>
    _requiredProperties = new List.from(value);
  _getMaxProperties(dynamic value) =>
    _maxProperties = _requireNonNegativeInt('maxProperties', value);
  _getMinProperties(dynamic value) =>
    _minProperties = _requireNonNegativeInt('minProperties', value);

  _getAllOf(Iterable value) =>
    _allOf = new List<Schema>.from(
      value.map((schema) =>
          new Schema.fromMap(schema, "$_path/allOf")));
  _getAnyOf(Iterable value) =>
    _anyOf = new List<Schema>.from(
      value.map((schema) =>
          new Schema.fromMap(schema, "$_path/anyOf")));
  _getOneOf(Iterable value) =>
    _oneOf = new List<Schema>.from(
      value.map((schema) =>
          new Schema.fromMap(schema, "$_path/oneOf")));
  _getDefault(dynamic value) => _defaultValue = value;

  static Map _accessMap = {
    "multipleOf" : (s, v) => s._getMultipleOf(v),
    "maximum" : (s, v) => s._getMaximum(v),
    "exclusiveMaximum" : (s, v) => s._getExclusiveMaximum(v),
    "minimum" : (s, v) => s._getMinimum(v),
    "exclusiveMinimum" : (s, v) => s._getExclusiveMinimum(v),
    "maxLength" : (s, v) => s._getMaxLength(v),
    "minLength" : (s, v) => s._getMinLength(v),
    "pattern" : (s, v) => s._getPattern(v),
    "type" : (s, v) => s._getType(v),
    "description" : (s, v) => s._getDescription(v),
    "id" : (s, v) => s._getId(v),
    "properties" : (s, v) => s._getPropertySchemas(v),
    "maxProperties": (s, v) => s._getMaxProperties(v),
    "minProperties": (s, v) => s._getMinProperties(v),
    "items" : (s, v) => s._getItems(v),
    "additionalItems" : (s, v) => s._getAdditionalItems(v),
    "maxItems": (s, v) => s._getMaxItems(v),
    "minItems": (s, v) => s._getMinItems(v),
    "uniqueItems": (s, v) => s._getUniqueItems(v),
    "required" : (s, v) => s._getRequired(v),
    "allOf" : (s, v) => s._getAllOf(v),
    "anyOf" : (s, v) => s._getAnyOf(v),
    "oneOf" : (s, v) => s._getOneOf(v),
    "default" : (s, v) => s._getDefault(v),
  };

  void _initialize() {

    _schemaMap.forEach((k, v) {
      var accessor = _accessMap[k];
      if(accessor != null) {
        accessor(this, v);
      }
    });

    if(_exclusiveMinimum != null && _minimum == null)
      throw new
        FormatException("$_path: 'exclusiveMinimum' requires 'minimum'");

    if(_exclusiveMaximum != null && _maximum == null) {
      throw new
        FormatException("$_path: 'exclusiveMaximum' requires 'maximum'");
    }

    if(isNumeric)
      _initializeNumericValidation();

  }

  static int _indent = 0;
  static String get _i {
    String i = '  ';
    for(int j=0; j<_indent; j++) i = i + '  ';
    return i;
  }

  String ppProperties() {
    _indent++;
    String i = _i;
    String result = _propertySchemas.length == 0? '[]' : '''

${i}[
${_propertySchemas.keys.map((property) => 
  '${i}$property' + _propertySchemas[property].toString()).join('\n')}
${i}]
''';
    _indent--;
    return result;
  }

  String toString() {
    _indent++;
    String i = _i;
    String result = '''

$i{
${i}  path: $_path
${i}  id: $_id
${i}  description: $_description
${i}  type: $_schemaType
${i}  multipleOf: $_multipleOf
${i}  maximum: $_maximum
${i}  exclusiveMaximum: $_exclusiveMaximum
${i}  minimum: $_minimum
${i}  exclusiveMinimum: $_exclusiveMinimum
${i}  properties:${ppProperties()}
${i}  allOf: $_allOf
${i}  anyOf: $_anyOf
${i}  oneOf: $_oneOf
${i}  items: $_items
${i}  additionalItems: $_additionalItems
${i}  required: $_requiredProperties
${i}}
''';
    _indent--;
    return result;
  }

  // end <class Schema>
}

class NumericSchema extends Schema {

  // custom <class NumericSchema>
  // end <class NumericSchema>
}

class StringSchema extends Schema {

  // custom <class StringSchema>
  // end <class StringSchema>
}

class ArraySchema extends Schema {

  // custom <class ArraySchema>
  // end <class ArraySchema>
}

class ObjectSchema extends Schema {

  // custom <class ObjectSchema>
  // end <class ObjectSchema>
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

