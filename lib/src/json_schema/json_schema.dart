part of json_schema;

/// Constructed with a json schema, either as string or Map. Validation of
/// the schema itself is done on construction. Any errors in the schema
/// result in a FormatException being thrown.
///
class Schema {
  Schema.fromMap(
    this._schemaMap
  ) {
    // custom <Schema.fromMap>
    _initialize();
    // end <Schema.fromMap>
  }
  
  Schema.fromString(
    this._schemaText
  ) {
    // custom <Schema.fromString>
    _schemaMap = JSON.parse(_schemaText);
    _initialize();
    // end <Schema.fromString>
  }
  
  Schema._fromMap(
    this._root,
    this._schemaMap,
    this._path
  ) {
    // custom <Schema._fromMap>
    _initialize();
    // end <Schema._fromMap>
  }
  
  String _schemaText;
  /// Text defining the schema for validation
  String get schemaText => _schemaText;
  Schema _root;
  Schema get root => _root;
  dynamic _schemaMap = {};
  dynamic get schemaMap => _schemaMap;
  String _path;
  String get path => _path;
  num _multipleOf;
  num get multipleOf => _multipleOf;
  num _maximum;
  num get maximum => _maximum;
  bool _exclusiveMaximum;
  num _minimum;
  num get minimum => _minimum;
  bool _exclusiveMinimum;
  int _maxLength;
  int get maxLength => _maxLength;
  int _minLength;
  int get minLength => _minLength;
  RegExp _pattern;
  RegExp get pattern => _pattern;
  List _enumValues;
  List get enumValues => _enumValues;
  List<Schema> _allOf;
  List<Schema> get allOf => _allOf;
  List<Schema> _anyOf;
  List<Schema> get anyOf => _anyOf;
  List<Schema> _oneOf;
  List<Schema> get oneOf => _oneOf;
  Schema _notSchema;
  Schema get notSchema => _notSchema;
  Map<String,Schema> _definitions;
  Map<String,Schema> get definitions => _definitions;
  Uri _id;
  Uri get id => _id;
  String _ref;
  String get ref => _ref;
  String _description;
  String get description => _description;
  String _title;
  String get title => _title;
  List<SchemaType> _schemaTypeList;
  List<SchemaType> get schemaTypeList => _schemaTypeList;
  Schema _items;
  /// To match all items to a schema
  Schema get items => _items;
  List<Schema> _itemsList;
  /// To match each item in array to a schema
  List<Schema> get itemsList => _itemsList;
  dynamic _additionalItems;
  dynamic get additionalItems => _additionalItems;
  int _maxItems;
  int get maxItems => _maxItems;
  int _minItems;
  int get minItems => _minItems;
  bool _uniqueItems = false;
  bool get uniqueItems => _uniqueItems;
  List<String> _requiredProperties;
  List<String> get requiredProperties => _requiredProperties;
  int _maxProperties;
  int get maxProperties => _maxProperties;
  int _minProperties = 0;
  int get minProperties => _minProperties;
  Map<String,Schema> _properties = {};
  Map<String,Schema> get properties => _properties;
  bool _additionalProperties;
  bool get additionalProperties => _additionalProperties;
  Schema _additionalPropertiesSchema;
  Schema get additionalPropertiesSchema => _additionalPropertiesSchema;
  Map<RegExp,Schema> _patternProperties = {};
  Map<RegExp,Schema> get patternProperties => _patternProperties;
  Map<String,Schema> _schemaDependencies;
  Map<String,Schema> get schemaDependencies => _schemaDependencies;
  Map<String,List<String>> _propertyDependencies;
  Map<String,List<String>> get propertyDependencies => _propertyDependencies;
  dynamic _defaultValue;
  dynamic get defaultValue => _defaultValue;
  /// Map of path to schema object
  Map<String,Schema> _refMap;
  /// Maps path to ref where path is location of schema referring to ref
  Map<String,String> _schemaRefs;
  /// Assignments to call for resolution upon end of parse
  List _schemaAssignments = [];

  // custom <class Schema>

  bool get exclusiveMaximum => _exclusiveMaximum == null || _exclusiveMaximum;
  bool get exclusiveMinimum => _exclusiveMinimum == null || _exclusiveMinimum;

  // All schema refs are stored in root
  Map<String,String> get _rootSchemaRefs => _root._schemaRefs;

  // All schemas are stored in root
  Map<String,Schema> get _rootRefMap => _root._refMap;

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
    if(value is num) {
      if(value <= 0) {
        _formatException("$_path: multipleOf must be > 0: $value");
      }
      _multipleOf = value;
    } else {
      _formatException("$_path: multipleOf must be a number: $value");
    }
  }
  _getMaximum(dynamic value) {
    if(value is num) {
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
    if(value is num) {
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
        String path = "$_path/properties/$property";
        if(_registerSchemaRef(path, subSchema)) {
          _schemaAssignments.add(() =>
              _properties[property] = resolvePath(path));
        } else {
          _properties[property] =
            _createSubSchema(subSchema, path);
        }
      });
    } else {
      _formatException("$_path: properties must be an object: $value");
    }
  }
  _getItems(dynamic value) {
    if(value is Map) {
      String path = "$_path/items";
      if(_registerSchemaRef(path, value)) {
        _schemaAssignments.add(() => _items = resolvePath(path));
      } else {
        _items = _createSubSchema(value, path);
      }
    } else if(value is List) {
      int index = 0;
      _itemsList = new List(value.length);
      for(int i=0; i<value.length; i++) {
        String path = "$_path/items/${index++}";
        if(_registerSchemaRef(path, value[i])) {
          _schemaAssignments.add(() => _itemsList[i] = resolvePath(path));
        } else {
          itemsList[i] = _createSubSchema(value[i], path);
        }
      }
    } else {
      _formatException("$_path: items must be object or array: $value");
    }
  }
  _getAdditionalItems(dynamic value) {
    if(value is bool) {
      _additionalItems = value;
    } else if(value is Map) {
      String path = "$_path/additionalItems";
      if(_registerSchemaRef(path, value)) {
        _schemaAssignments.add(() => _additionalItems = resolvePath(path));
      } else {
        _additionalItems = _createSubSchema(value, path);
      }
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
      String path = "$_path/additionalProperties";
      if(_registerSchemaRef(path, value)) {
        _schemaAssignments.add(() =>
            _additionalPropertiesSchema = resolvePath(path));
      } else {
        _additionalPropertiesSchema = _createSubSchema(value, path);
      }
    } else {
      _formatException(
        "$_path: additionalProperities must be a bool or schema: $value");
    }
  }
  _getPatternProperties(dynamic value) {
    if(value is Map) {
      value.forEach((k, v) {
        String path = "$_path/patternProperties/$k";
        if(_registerSchemaRef(path, v)) {
          _schemaAssignments.add(() =>
              _patternProperties[new RegExp(k)] = resolvePath(path));
        } else {
          _patternProperties[new RegExp(k)] = _createSubSchema(v, path);
        }
      });
    } else {
      _formatException(
        "$_path: patternProperties must be an object: $value");
    }
  }
  _getDependencies(dynamic value) {
    if(value is Map) {
      value.forEach((k, v) {
        if(v is Map) {
          if(_schemaDependencies == null) _schemaDependencies = {};

          String path = "$_path/dependencies/$k";
          if(_registerSchemaRef(path, v)) {
            _schemaAssignments.add(() => 
                _schemaDependencies[k] = resolvePath(path));
          } else {
            _schemaDependencies[k] = _createSubSchema(v, path);
          }
        } else if(v is List) {
          if(v.length == 0)
            _formatException(
              "$_path: property deps must be non-empty array");
          if(_propertyDependencies == null) _propertyDependencies = {};

          Set uniqueDeps = new Set();
          v.forEach((propDep) {
            if(propDep is String) {
              if(uniqueDeps.contains(propDep)) {
                _formatException(
                  "$_path: property deps must be unique: $v");
              } else {
                _propertyDependencies.putIfAbsent(k, ()=>[]).add(propDep);
                uniqueDeps.add(propDep);
              }
            } else {
              _formatException(
                "$_path: property deps must be strings: $v");
            }
          });
        } else {
          _formatException(
            "$_path: dependency values must be object or array: $v");
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
      int i = 0;
      value.forEach((v) {
        for(int j=i+1; j<value.length; j++) {
          if(_jsonEqual(value[i], value[j]))
              _formatException(
                "$_path: enum values must be unique: $value [$i]==[$j]");
        }
        i++;
        _enumValues.add(v);
      });
    } else {
      _formatException("$_path: enum must be an array: $value");
    }
  }
  _getType(dynamic value) {
    if(value is String) {
      _schemaTypeList = [ SchemaType.fromString(value) ];
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
      for(int i=0; i<value.length; i++) {
        var v = value[i];
        String path = "$_path/$key/$i";
        if(_registerSchemaRef(path, v)) {
          _schemaAssignments.add(() => result[i] = resolvePath(path));
        } else {
          result[i] = _createSubSchema(v, path);
        }
      }
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
      String path = "$_path/not";
      if(_registerSchemaRef(path, value)) {
        _schemaAssignments.add(() => _notSchema = resolvePath(path));
      } else {
        _notSchema = _createSubSchema(value, path);
      }
    } else {
      _formatException("$_path: not must be object: $value");
    }
  }
  _getDefinitions(dynamic value) {
    if(value is Map) {
      _definitions = {};
      value.forEach((k,v) {
        String path = "$_path/definitions/$k";
        if(_registerSchemaRef(path, v)) {
          _schemaAssignments.add(() => _definitions[k] = resolvePath(path));
        } else {
          _definitions[k] = _createSubSchema(v, path);
        }
      });

    } else {
      _formatException("$_path: definition must be an object: $value");
    }
  }
  _getRef(dynamic value) {
    if(value is String) {
      _ref = value;
    } else {
      _formatException("$_path: \$ref must be a string: $value");
    }
  }
  _getId(dynamic value) {
    if(value is String) {
      String id = _requireString("id", value);
      try {
        _id = Uri.parse(id);
      } catch(e) {
        _formatException("$_path: id must be a valid URI: $value");
      }
    } else {
      _formatException("$_path: id must be a string: $value");
    }
  }
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
    "\$ref" : (s, v) => s._getRef(v),
    "title" : (s, v) => s._getTitle(v),
    "description" : (s, v) => s._getDescription(v),
  };

  void _initialize() {
    if(_root == null) {
      _root = this;
      _path = '#';
      _refMap = { '#' : this };
    }
    if(!(_schemaMap is Map))
      _formatException("$_path: schema definition must be a map");

    _schemaMap.forEach((k, v) {
      var accessor = _accessMap[k];
      if(accessor != null) {
        accessor(this, v);
      } else {
        _formatException("$_path: $k is not valid property for schema");
      }
    });

    if(_exclusiveMinimum != null && _minimum == null)
      _formatException("$_path: exclusiveMinimum requires minimum");

    if(_exclusiveMaximum != null && _maximum == null)
      _formatException("$_path: exclusiveMaximum requires maximum");

    if(_root == this && _schemaRefs != null) {
      _logger.info("The following need to be resolved ${_schemaRefs}");
      _logger.info("The following are available: ${_refMap.keys.toList()}");
      _schemaRefs.forEach((path, reference) {
        Schema match = _refMap[reference];
        if(match != null) {
          assert(path == '#' || _refMap[path] ==null);
          _refMap[path] = match;
          _logger.info("Matched $path to schema $reference ${match._schemaMap}");
        } else {
          _logger.info("No match to $reference at $path found in schema");
        }
      });
    }

    _schemaAssignments.forEach((assignment) => assignment());

  }

  Schema resolvePath(String path) {
    path = _normalizePath(path);
    Schema result = _refMap[path];
    assert(result != null);
    return result;
  }

  bool _registerSchemaRef(path, dynamic schemaDefinition) {
    if(schemaDefinition is Map) {
      String ref = schemaDefinition[r"$ref"];
      if(ref != null) {
        if(_rootSchemaRefs == null) _root._schemaRefs = {};
        _rootSchemaRefs[path] = ref;
        return true;
      }
    }
    return false;
  }

  static String _normalizePath(String path) => path;
//    path.replaceAll('~', '~0')
//    .replaceAll('/', '~1')
//    .replaceAll('%', '%25');

  Schema _createSubSchema(dynamic schemaDefinition, String path) {
    path = _normalizePath(path);
    assert(_rootSchemaRefs == null || _rootSchemaRefs[path] != null);
    assert(!_root._refMap.containsKey(path));
    Schema result = new Schema._fromMap(_root, schemaDefinition, path);
    _root._refMap[path] = result;
    return result;
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
${i}  type: $_schemaTypeList
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
// custom <part json_schema>
// end <part json_schema>

