/// Support for validating json instances against a json schema
library json_schema;

import "dart:io";
import "dart:json" as JSON;
import "package:plus/pprint.dart";
import "package:logging/logging.dart";
import "package:logging_handlers/logging_handlers_shared.dart";

final _logger = new Logger("json_schema");

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
  dynamic _schemaMap = {};
  String _path;
  num _multipleOf;
  num _maximum;
  bool _exclusiveMaximum;
  num _minimum;
  bool _exclusiveMinimum;
  int _maxLength;
  int _minLength;
  RegExp _pattern;
  List _enumValues;
  SchemaType _schemaType;
  List<Schema> _allOf;
  List<Schema> _anyOf;
  List<Schema> _oneOf;
  Schema _notSchema;
  Map<String,Schema> _definitions;
  String _id;
  String _description;
  String _title;
  List<SchemaType> _schemaTypeList;
  Map<String,Schema> _properties = {};
  Schema _items;
  List<Schema> _itemsList;
  dynamic _additionalItems;
  int _maxItems;
  int _minItems;
  bool _uniqueItems = false;
  List<String> _requiredProperties;
  int _maxProperties;
  int _minProperties;
  bool _additionalProperties;
  Schema _additionalPropertiesSchema;
  Map _patternProperties;
  Map<String,Schema> _schemaDependencies;
  List<String> _propertyDependencies;
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

  String _requireString(String key, dynamic value) {
    if(value is String) return value;
    _formatException("$_path: $key must be a string: $value");
  }

  dynamic _requirePositive(String key, dynamic value) {
    if(value <= 0) _formatException("$_path: $key must be > 0: $value");
    return value;
  }

  int _requirePositiveInt(String key, dynamic value) {
    if(value is int) return _requirePositive(key, value);
    _formatException("$_path: $key must be an int: $value");
  }

  dynamic _requireNonNegative(String key, dynamic value) {
    if(value < 0)
      _formatException("$_path: $key must be non-negative: $value");
    return value;
  }

  int _requireNonNegativeInt(String key, dynamic value) {
    if(value is int) return _requireNonNegative(key, value);
    _formatException("$_path: $key must be an int: $value");
  }

  _getMultipleOf(dynamic value) {
    if((value is num) || (value is int)) {
      if(value <= 0) {
        _formatException("$_path: multipleOf must be > 0: $value");
      }
      _multipleOf = value;
    } else {
      _formatException("$_path: multipleOf must be a number: $value");
    }
  }
  _getMaximum(dynamic value) {
    if((value is num) || (value is int)) {
      _maximum = value;
    } else {
      _formatException("$_path: maximum must be a number: $value");
    }
  }
  _getExclusiveMaximum(dynamic value) {
    if(value is bool) {
      _exclusiveMaximum = value;
    } else {
      _formatException("$_path: exclusiveMaximum must be a bool: $value");
    }
  }
  _getMinimum(dynamic value) {
    if((value is num) || (value is int)) {
      _minimum = value;
    } else {
      _formatException("$_path: minimum must be a number: $value");
    }
  }
  _getExclusiveMinimum(dynamic value) {
    if(value is bool) {
      _exclusiveMinimum = value;
    } else {
      _formatException("$_path: exclusiveMinimum must be a boolean: $value");
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
      _formatException("$_path: pattern must be a string: value");
    }
  }
  _getProperties(dynamic value) {
    if(value is Map) {
      value.forEach((property, subSchema) {
        _properties[property] =
          new Schema.fromMap(subSchema, "$_path/properties/$property");
      });
    } else {
      _formatException("$_path: properties must be an object: $value");
    }
  }
  _getItems(dynamic value) {
    if(value is Map) {
      _items = new Schema.fromMap(value, "$_path/items");
    } else if(value is List) {
      int index = 0;
      _itemsList = value.map((item) => 
          new Schema.fromMap(item, "$_path/items/${index++}")).toList();
    } else {
      _formatException("$_path: items must be object or array: $value");
    }
  }
  _getAdditionalItems(dynamic value) {
    if(value is bool) {
      _additionalItems = value;
    } else if(value is Map) {
      _additionalItems = new Schema.fromMap(value, "$_path/additionalItems");
    } else {
      _formatException(
        "$_path: additionalItems must be bool or object: $value");
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
      _formatException("$_path: uniqueItems must be bool: $value");
    }
  }
  _getRequired(dynamic value) {
    if(value is List) {
      if(value.length == 0)
        _formatException("$_path: required must be a non-empty array");

      _requiredProperties = new List.from(value);
    } else {
      _formatException("$_path: required must be an array: $value");
    }
  }

  _getMaxProperties(dynamic value) =>
    _maxProperties = _requireNonNegativeInt('maxProperties', value);
  _getMinProperties(dynamic value) =>
    _minProperties = _requireNonNegativeInt('minProperties', value);

  _getAdditionalProperties(dynamic value) {
    if(value is bool) {
      _additionalProperties = value;
    } else if(value is Map) {
      _additionalPropertiesSchema =
        new Schema.fromMap(schema, "$_path/additionalProperties");
    } else {
      _formatException(
        "$_path: additionalProperities must be a bool or schema: $value");
    }
  }
  _getPatternProperties(dynamic value) {
    if(value is Map) {
      _patternProperties = {};
      value.forEach((k, v) {
        _patternProperties[new RegExp(k)] =
          new Schema.fromMap(v, "$_path/patternProperties/$k");
      });
    } else {
      _formatException(
        "$_path: patternProperties must be an object: $value");
    }
  }
  _getDependencies(dynamic value) {
    if(value is Map) {
      _schemaDependencies = {};
      _propertyDependencies = [];
      value.forEach((k, v) {
        if(v is Map) {
          _schemaDependencies[k] =
            new Schema.fromMap(v, "$_path/dependencies/$k");
        } else if(v is List) {
          if(v.length == 0)
            _formatException(
              "$_path: property deps must be non-empty array");
          Set uniqueDeps = new Set();
          v.forEach((propDep) {
            if(propDep is String) {
              if(uniqueDeps.contains(propDep)) {
                _formatException(
                  "$_path: property deps must be unique: $v");
              } else {
                _propertyDependencies.add(propDep);
                uniqueDeps.add(propDep);
              }
            } else {
              _formatException(
                "$_path: property deps must be strings: $v");
            }
          });
        }
      });
    } else {
      _formatException(
        "$_path: dependencies must be an object: $value");
    }
  }
  _getEnum(dynamic value) {
    _enumValues = [];
    if(value is List) {
      if(value.length == 0)
        _formatException("$_path: enum must be a non-empty array");
      int i = 1;
      value.forEach((v) {
        for(int j=i; j<value.length; j++) {
          if(_jsonEqual(value[i], value[j]))
              _formatException("$_path: enum values must be unique: $value");
          i++;
        }
        _enumValues.add(v);
      });
    } else {
      _formatException("$_path: enum must be an array: $value");
    }
  }
  _getType(dynamic value) {
    if(value is String) {
      _schemaType = SchemaType.fromString(value);
    } else if(value is List) {
      _schemaTypeList = value.map((v) =>
          SchemaType.fromString(v)).toList();
    } else {
      _formatException("$_path: type must be string or array: $value");
    }
  }

  List _requireListOfSchema(String key, dynamic value) {
    if(value is List) {
      if(value.length == 0)
        _formatException("$_path: $key array must not be empty");
      List result = new List(value.length);
      value.forEach((v) {
        result.add(
          new Schema.fromMap(v, "$_path/$key"));
      });
      return result;
    } else {
      _formatException("$_path: $key must be an array");
    }
  }

  _getAllOf(dynamic value) =>
    _allOf = _requireListOfSchema("allOf", value);
  _getAnyOf(dynamic value) =>
    _anyOf = _requireListOfSchema("anyOf", value);
  _getOneOf(dynamic value) =>
    _oneOf = _requireListOfSchema("oneOf", value);
  _getNot(dynamic value) {
    if(value is Map) {
      _notSchema = new Schema.fromMap(value, "$_path/not");
    } else {
      _formatException("$_path: not must be object: $value");
    }
  }
  _getDefinitions(dynamic value) {
    if(value is Map) {
      _definitions = {};
      value.forEach((k,v) {
        _definitions[k] =
          new Schema.fromMap(v, "$_path/definitions");
      });
    } else {
      _formatException("$_path: must be an object: $value");
    }
  }
  _getId(dynamic value) => _id = _requireString("id", value);
  _getTitle(dynamic value) => _title = _requireString("title", value);
  _getDescription(dynamic value) =>
    _description = _requireString("description", value);
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
    "properties" : (s, v) => s._getProperties(v),
    "maxProperties": (s, v) => s._getMaxProperties(v),
    "minProperties": (s, v) => s._getMinProperties(v),
    "additionalProperties" : (s, v) => s._getAdditionalProperties(v),
    "dependencies": (s, v) => s._getDependencies(v),
    "patternProperties" : (s, v) => s._getPatternProperties(v),
    "items" : (s, v) => s._getItems(v),
    "additionalItems" : (s, v) => s._getAdditionalItems(v),
    "maxItems": (s, v) => s._getMaxItems(v),
    "minItems": (s, v) => s._getMinItems(v),
    "uniqueItems": (s, v) => s._getUniqueItems(v),
    "required" : (s, v) => s._getRequired(v),
    "default" : (s, v) => s._getDefault(v),
    "enum" : (s, v) => s._getEnum(v),
    "type" : (s, v) => s._getType(v),
    "allOf" : (s, v) => s._getAllOf(v),
    "anyOf" : (s, v) => s._getAnyOf(v),
    "oneOf" : (s, v) => s._getOneOf(v),
    "not" : (s, v) => s._getNot(v),
    "definitions" : (s, v) => s._getDefinitions(v),
    "id" : (s, v) => s._getId(v),
    "title" : (s, v) => s._getTitle(v),
    "description" : (s, v) => s._getDescription(v),
  };

  void _initialize() {
    if(!(_schemaMap is Map)) 
      _formatException("$_path: schema definition must be a map");

    _schemaMap.forEach((k, v) {
      var accessor = _accessMap[k];
      if(accessor != null) {
        accessor(this, v);
      }
    });

    if(_exclusiveMinimum != null && _minimum == null)
      _formatException("$_path: exclusiveMinimum requires minimum");

    if(_exclusiveMaximum != null && _maximum == null)
      _formatException("$_path: exclusiveMaximum requires maximum");

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
    String result = _properties.length == 0? '[]' : '''

${i}[
${_properties.keys.map((property) => 
  '${i}$property' + _properties[property].toString()).join('\n')}
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

bool logFormatExceptions = false;

void _formatException(String msg) {
  if(logFormatExceptions)
    _logger.warning(msg);
  throw new FormatException(msg);
}

bool _jsonEqual(a, b) {
  bool result = true;
  if(a is Map && b is Map) {
    if(a.length != b.length) return false;
    a.keys.forEach((k) {
      if(!jsonEqual(a[k], b[k])) {
        result = false;
        return;
      }
    });
  } else if(a is List && b is List) {
    if(a.length != b.length) return false;
    for(int i=0; i<a.length; i++) {
      if(!jsonEqual(a[i], b[i])) {
        result = false;
        return;
      }
    }
  } else {
    return a == b;
  }
  return result;
}

ISchema createSchema(Map schema, [ String path ]) {
  SchemaType schemaType = SchemaType.fromString(_schemaMap["type"]);
  
}

// end <library json_schema>

