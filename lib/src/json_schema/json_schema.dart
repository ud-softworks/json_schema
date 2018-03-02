// Copyright 2013-2018 Workiva Inc.
//
// Licensed under the Boost Software License (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.boost.org/LICENSE_1_0.txt
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This software or document includes material copied from or derived
// from JSON-Schema-Test-Suite (https://github.com/json-schema-org/JSON-Schema-Test-Suite),
// Copyright (c) 2012 Julian Berman, which is licensed under the following terms:
//
//     Copyright (c) 2012 Julian Berman
//
//     Permission is hereby granted, free of charge, to any person obtaining a copy
//     of this software and associated documentation files (the "Software"), to deal
//     in the Software without restriction, including without limitation the rights
//     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//     copies of the Software, and to permit persons to whom the Software is
//     furnished to do so, subject to the following conditions:
//
//     The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//     THE SOFTWARE.

import 'dart:async';

import 'package:path/path.dart' as path_lib;

import 'package:json_schema/src/json_schema/schema_type.dart';
import 'package:json_schema/src/json_schema/validator.dart';
import 'package:json_schema/src/json_schema/global_platform_functions.dart';
import 'package:json_schema/src/json_schema/utils.dart';
import 'package:json_schema/src/json_schema/format_exceptions.dart';
import 'package:json_schema/src/json_schema/type_validators.dart';

/// Constructed with a json schema, either as string or Map. Validation of
/// the schema itself is done on construction. Any errors in the schema
/// result in a FormatException being thrown.
class JsonSchema {
  JsonSchema._fromMap(this._root, this._schemaMap, this._path) {
    _initialize();
    _addSchema(path, this);
  }

  JsonSchema._fromRootMap(this._schemaMap) {
    _initialize();
  }

  /// Create a schema from a [data]
  /// Typically [data] is result of JSON.decode(jsonSchemaString)
  static Future<JsonSchema> createSchema(Map data) => new JsonSchema._fromRootMap(data)._thisCompleter.future;

  static Future<JsonSchema> createSchemaFromUrl(String schemaUrl) {
    if (globalCreateJsonSchemaFromUrl == null) {
      throw new StateError('no globalCreateJsonSchemaFromUrl defined!');
    }
    return globalCreateJsonSchemaFromUrl(schemaUrl);
  }

  /// Construct and validate a JsonSchema.
  void _initialize() {
    if (_root == null) {
      _root = this;
      _path = '#';
      _addSchema('#', this);
      _thisCompleter = new Completer();
    } else {
      _schemaRefs = _root._schemaRefs;
      _refMap = _root._refMap;
      _freeFormMap = _root._freeFormMap;
      _thisCompleter = _root._thisCompleter;
      _schemaAssignments = _root._schemaAssignments;
    }

    _validateSchema();
  }

  /// Validate that a given JsonSchema conforms to a spec.
  void _validateSchema() {
    // _logger.info('Validating schema $_path'); TODO: re-add logger

    if (_registerSchemaRef(_path, _schemaMap)) {
      // _logger.info('Top level schema is ref: $_schemaRefs'); TODO: re-add logger
    }

    _schemaMap.forEach((k, v) {
      final accessor = _accessMap[k];
      if (accessor != null) {
        accessor(this, v);
      } else {
        _freeFormMap[path_lib.join(_path, JsonSchemaUtils.normalizePath(k))] = v;
      }
    });

    if (_exclusiveMinimum != null && _minimum == null)
      throw FormatExceptions.error('exclusiveMinimum requires minimum');

    if (_exclusiveMaximum != null && _maximum == null)
      throw FormatExceptions.error('exclusiveMaximum requires maximum');

    if (_root == this) {
      _schemaAssignments.forEach((assignment) => assignment());
      if (_retrievalRequests.isNotEmpty) {
        Future.wait(_retrievalRequests).then((_) => _thisCompleter.complete(_resolvePath('#')));
      } else {
        _thisCompleter.complete(_resolvePath('#'));
      }
      // _logger.info('Marked $_path complete'); TODO: re-add logger
    }

    // _logger.info('Completed Validating schema $_path'); TODO: re-add logger
  }

  JsonSchema _resolvePath(String original) {
    final String path = endPath(original);
    final JsonSchema result = _refMap[path];
    if (result == null) {
      final schema = _freeFormMap[path];
      if (schema is! Map) throw FormatExceptions.schema('free-form property $original at $path', schema);
      return new JsonSchema._fromMap(_root, schema, path);
    }
    return result;
  }

  JsonSchema _createSubSchema(dynamic schemaDefinition, String path) {
    assert(!_schemaRefs.containsKey(path));
    assert(!_refMap.containsKey(path));
    return new JsonSchema._fromMap(_root, schemaDefinition, path);
  }

  JsonSchema _root;
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
  List _enumValues = [];
  List<JsonSchema> _allOf = [];
  List<JsonSchema> _anyOf = [];
  List<JsonSchema> _oneOf = [];
  JsonSchema _notSchema;
  Map<String, JsonSchema> _definitions = {};
  Uri _id;
  String _ref;
  String _description;
  String _title;
  List<SchemaType> _schemaTypeList;
  JsonSchema _items;
  List<JsonSchema> _itemsList;
  dynamic _additionalItems;
  int _maxItems;
  int _minItems;
  bool _uniqueItems = false;
  List<String> _requiredProperties;
  int _maxProperties;
  int _minProperties = 0;
  Map<String, JsonSchema> _properties = {};
  bool _additionalProperties;
  JsonSchema _additionalPropertiesSchema;
  Map<RegExp, JsonSchema> _patternProperties = {};
  Map<String, JsonSchema> _schemaDependencies = {};
  Map<String, List<String>> _propertyDependencies = {};
  dynamic _defaultValue;
  Map<String, JsonSchema> _refMap = {};

  /// For schemas with $ref maps path of schema to $ref path
  Map<String, String> _schemaRefs = {};

  /// Assignments to call for resolution upon end of parse
  List _schemaAssignments = [];

  /// Maps any non-key top level property to its original value
  Map<String, dynamic> _freeFormMap = {};

  /// Completer that fires when the JsonSchema has finished building.
  Completer _thisCompleter = new Completer();

  /// HTTP(S) requests to fetch ref'd schemas.
  List<Future<JsonSchema>> _retrievalRequests = [];

  /// Set of strings to gaurd against path cycles
  Set<String> _pathsEncountered = new Set();

  /// Support for optional formats (date-time, uri, email, ipv6, hostname)
  String _format;

  /// Map to allow getters to be accessed by String key.
  static Map _accessMap = {
    'multipleOf': (s, v) => s._setMultipleOf(v),
    'maximum': (s, v) => s._setMaximum(v),
    'exclusiveMaximum': (s, v) => s._setExclusiveMaximum(v),
    'minimum': (s, v) => s._setMinimum(v),
    'exclusiveMinimum': (s, v) => s._setExclusiveMinimum(v),
    'maxLength': (s, v) => s._setMaxLength(v),
    'minLength': (s, v) => s._setMinLength(v),
    'pattern': (s, v) => s._setPattern(v),
    'properties': (s, v) => s._setProperties(v),
    'maxProperties': (s, v) => s._setMaxProperties(v),
    'minProperties': (s, v) => s._setMinProperties(v),
    'additionalProperties': (s, v) => s._setAdditionalProperties(v),
    'dependencies': (s, v) => s._setDependencies(v),
    'patternProperties': (s, v) => s._setPatternProperties(v),
    'items': (s, v) => s._setItems(v),
    'additionalItems': (s, v) => s._setAdditionalItems(v),
    'maxItems': (s, v) => s._setMaxItems(v),
    'minItems': (s, v) => s._setMinItems(v),
    'uniqueItems': (s, v) => s._setUniqueItems(v),
    'required': (s, v) => s._setRequired(v),
    'default': (s, v) => s._setDefault(v),
    'enum': (s, v) => s._setEnum(v),
    'type': (s, v) => s._setType(v),
    'allOf': (s, v) => s._setAllOf(v),
    'anyOf': (s, v) => s._setAnyOf(v),
    'oneOf': (s, v) => s._setOneOf(v),
    'not': (s, v) => s._setNot(v),
    'definitions': (s, v) => s._setDefinitions(v),
    'id': (s, v) => s._setId(v),
    '\$ref': (s, v) => s._setRef(v),
    '\$schema': (s, v) => s._setSchema(v),
    'title': (s, v) => s._setTitle(v),
    'description': (s, v) => s._setDescription(v),
    'format': (s, v) => s._setFormat(v),
  };

  /// Get a nested JsonSchema from a path.
  JsonSchema resolvePath(String path) {
    while (_schemaRefs.containsKey(path)) {
      path = _schemaRefs[path];
    }
    return _refMap[path];
  }

  @override
  String toString() => '${_schemaMap}';

  // --------------------------------------------------------------------------
  // Root Schema
  // --------------------------------------------------------------------------
  JsonSchema get root => _root;
  Map get schemaMap => _schemaMap;
  String get path => _path;
  num get multipleOf => _multipleOf;
  num get maximum => _maximum;
  num get minimum => _minimum;
  int get maxLength => _maxLength;
  int get minLength => _minLength;
  RegExp get pattern => _pattern;
  List get enumValues => _enumValues;
  List<JsonSchema> get allOf => _allOf;
  List<JsonSchema> get anyOf => _anyOf;
  List<JsonSchema> get oneOf => _oneOf;
  JsonSchema get notSchema => _notSchema;
  Map<String, JsonSchema> get definitions => _definitions;
  Uri get id => _id;
  String get ref => _ref;
  String get description => _description;
  String get title => _title;
  List<SchemaType> get schemaTypeList => _schemaTypeList;
  String get format => _format;

  // --------------------------------------------------------------------------
  // Schema Items
  // --------------------------------------------------------------------------

  /// To match all items to a schema
  JsonSchema get items => _items;

  /// To match each item in array to a schema
  List<JsonSchema> get itemsList => _itemsList;
  dynamic get additionalItems => _additionalItems;
  int get maxItems => _maxItems;
  int get minItems => _minItems;
  bool get uniqueItems => _uniqueItems;

  // --------------------------------------------------------------------------
  // Schema Properties
  // --------------------------------------------------------------------------
  List<String> get requiredProperties => _requiredProperties;
  int get maxProperties => _maxProperties;
  int get minProperties => _minProperties;
  Map<String, JsonSchema> get properties => _properties;
  bool get additionalProperties => _additionalProperties;
  JsonSchema get additionalPropertiesSchema => _additionalPropertiesSchema;
  Map<RegExp, JsonSchema> get patternProperties => _patternProperties;
  Map<String, JsonSchema> get schemaDependencies => _schemaDependencies;
  Map<String, List<String>> get propertyDependencies => _propertyDependencies;
  dynamic get defaultValue => _defaultValue;

  /// Map of path to schema object
  Map<String, JsonSchema> get refMap => _refMap;

  /// Validate [instance] against this schema
  bool validate(dynamic instance) => new Validator(this).validate(instance);

  bool get exclusiveMaximum => _exclusiveMaximum == null || _exclusiveMaximum;
  bool get exclusiveMinimum => _exclusiveMinimum == null || _exclusiveMinimum;

  bool propertyRequired(String property) => _requiredProperties != null && _requiredProperties.contains(property);

  /// Given path, follow all references to an end path pointing to schema
  String endPath(String path) {
    _pathsEncountered.clear();
    return _endPath(path);
  }

  /// Returns paths of all paths
  Set get paths => new Set.from(_schemaRefs.keys)..addAll(_refMap.keys);

  String _endPath(String path) {
    if (_pathsEncountered.contains(path))
      throw FormatExceptions.error('Encountered path cycle ${_pathsEncountered}, adding $path');

    final referredTo = _schemaRefs[path];
    if (referredTo == null) {
      return path;
    } else {
      _pathsEncountered.add(path);
      return _endPath(referredTo);
    }
  }

  bool _registerSchemaRef(String path, dynamic schemaDefinition) {
    if (schemaDefinition is Map) {
      final dynamic ref = schemaDefinition[r'$ref'];
      if (ref != null) {
        if (ref is String) {
          // _logger.info('Linking $path to $ref'); TODO: re-add logger
          _schemaRefs[path] = ref;
          return true;
        } else {
          throw FormatExceptions.string('\$ref', ref);
        }
      }
    }
    return false;
  }

  /// Add a ref'd JsonSchema to the map of available Schemas.
  _addSchema(String path, JsonSchema schema) => _refMap[path] = schema;

  _makeSchema(String path, dynamic schema, assigner(JsonSchema rhs)) {
    if (schema is! Map) throw FormatExceptions.schema(path, schema);
    if (_registerSchemaRef(path, schema)) {
      _schemaAssignments.add(() => assigner(_resolvePath(path)));
    } else {
      assigner(_createSubSchema(schema, path));
    }
  }

  _validateListOfSchema(String key, dynamic value, schemaAdder(JsonSchema schema)) {
    if (value is List) {
      if (value.length == 0) throw FormatExceptions.error('$key array must not be empty');
      for (int i = 0; i < value.length; i++) {
        _makeSchema('$_path/$key/$i', value[i], (rhs) => schemaAdder(rhs));
      }
    } else {
      throw FormatExceptions.list(key, value);
    }
  }

  _setMultipleOf(dynamic value) => _multipleOf = TypeValidators.nonNegativeNum('multiple', value);
  _setMaximum(dynamic value) => _maximum = TypeValidators.number('maximum', value);
  _setExclusiveMaximum(dynamic value) => _exclusiveMaximum = TypeValidators.boolean('exclusiveMaximum', value);
  _setMinimum(dynamic value) => _minimum = TypeValidators.number('minimum', value);
  _setExclusiveMinimum(dynamic value) => _exclusiveMinimum = TypeValidators.boolean('exclusiveMinimum', value);
  _setMaxLength(dynamic value) => _maxLength = TypeValidators.nonNegativeInt('maxLength', value);
  _setMinLength(dynamic value) => _minLength = TypeValidators.nonNegativeInt('minLength', value);
  _setPattern(dynamic value) => _pattern = new RegExp(TypeValidators.string('pattern', value));

  /// Set sub-items or properties of the schema that are also JsonSchemas.
  _setProperties(dynamic value) => (TypeValidators.object('properties', value)).forEach((property, subSchema) =>
      _makeSchema('$_path/properties/$property', subSchema, (rhs) => _properties[property] = rhs));
  _setItems(dynamic value) {
    if (value is Map) {
      _makeSchema('$_path/items', value, (rhs) => _items = rhs);
    } else if (value is List) {
      int index = 0;
      _itemsList = new List(value.length);
      for (int i = 0; i < value.length; i++) {
        _makeSchema('$_path/items/${index++}', value[i], (rhs) => _itemsList[i] = rhs);
      }
    } else {
      throw FormatExceptions.error('items must be object or array: $value');
    }
  }

  _setAdditionalItems(dynamic value) {
    if (value is bool) {
      _additionalItems = value;
    } else if (value is Map) {
      _makeSchema('$_path/additionalItems', value, (rhs) => _additionalItems = rhs);
    } else {
      throw FormatExceptions.error('additionalItems must be boolean or object: $value');
    }
  }

  _setMaxItems(dynamic value) => _maxItems = TypeValidators.nonNegativeInt('maxItems', value);
  _setMinItems(dynamic value) => _minItems = TypeValidators.nonNegativeInt('minItems', value);
  _setUniqueItems(dynamic value) => _uniqueItems = TypeValidators.boolean('uniqueItems', value);
  _setRequired(dynamic value) => _requiredProperties = TypeValidators.nonEmptyList('required', value);
  _setMaxProperties(dynamic value) => _maxProperties = TypeValidators.nonNegativeInt('maxProperties', value);
  _setMinProperties(dynamic value) => _minProperties = TypeValidators.nonNegativeInt('minProperties', value);
  _setAdditionalProperties(dynamic value) {
    if (value is bool) {
      _additionalProperties = value;
    } else if (value is Map) {
      _makeSchema('$_path/additionalProperties', value, (rhs) => _additionalPropertiesSchema = rhs);
    } else {
      throw FormatExceptions.error('additionalProperties must be a bool or valid schema object: $value');
    }
  }

  _setPatternProperties(dynamic value) => (TypeValidators.object('patternProperties', value)).forEach(
      (k, v) => _makeSchema('$_path/patternProperties/$k', v, (rhs) => _patternProperties[new RegExp(k)] = rhs));
  _setDependencies(dynamic value) => (TypeValidators.object('dependencies', value)).forEach((k, v) {
        if (v is Map) {
          _makeSchema('$_path/dependencies/$k', v, (rhs) => _schemaDependencies[k] = rhs);
        } else if (v is List) {
          if (v.length == 0) throw FormatExceptions.error('property dependencies must be non-empty array');

          final Set uniqueDeps = new Set();
          v.forEach((propDep) {
            if (propDep is! String) throw FormatExceptions.string('propertyDependency', v);

            if (uniqueDeps.contains(propDep)) throw FormatExceptions.error('property dependencies must be unique: $v');

            _propertyDependencies.putIfAbsent(k, () => []).add(propDep);
            uniqueDeps.add(propDep);
          });
        } else {
          throw FormatExceptions.error('dependency values must be object or array: $v');
        }
      });

  _setEnum(dynamic value) => _enumValues = TypeValidators.uniqueList('enum', value);
  _setType(dynamic value) => _schemaTypeList = TypeValidators.schemaTypeList('type', value);
  _setAllOf(dynamic value) => _validateListOfSchema('allOf', value, (schema) => _allOf.add(schema));
  _setAnyOf(dynamic value) => _validateListOfSchema('anyOf', value, (schema) => _anyOf.add(schema));
  _setOneOf(dynamic value) => _validateListOfSchema('oneOf', value, (schema) => _oneOf.add(schema));
  _setSchema(dynamic value) => TypeValidators.jsonSchemaVersion4(r'$ref', value);
  _setId(dynamic value) => _id = TypeValidators.uri('id', value);
  _setTitle(dynamic value) => _title = TypeValidators.string('title', value);
  _setDescription(dynamic value) => _description = TypeValidators.string('description', value);
  _setDefault(dynamic value) => _defaultValue = value;
  _setFormat(dynamic value) => _format = TypeValidators.string('format', value);
  _setNot(dynamic value) => _makeSchema('$_path/not', TypeValidators.object('not', value), (rhs) => _notSchema = rhs);
  _setDefinitions(dynamic value) => (TypeValidators.object('definition', value))
      .forEach((k, v) => _makeSchema('$_path/definitions/$k', v, (rhs) => _definitions[k] = rhs));
  _setRef(dynamic value) {
    _ref = TypeValidators.nonEmptyString(r'$ref', value);
    if (_ref[0] != '#') {
      final refSchemaFuture = createSchemaFromUrl(_ref).then((schema) => _addSchema(_ref, schema));
      _retrievalRequests.add(refSchemaFuture);
    }
  }
}
