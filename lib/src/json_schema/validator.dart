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

import 'dart:math';

import 'package:json_schema/src/json_schema/constants.dart';
import 'package:json_schema/src/json_schema/json_schema.dart';
import 'package:json_schema/src/json_schema/schema_type.dart';
import 'package:json_schema/src/json_schema/utils.dart';
import 'package:json_schema/src/json_schema/global_platform_functions.dart' show defaultValidators;

/// Initialized with schema, validates instances against it
class Validator {
  Validator(this._rootSchema);

  List<String> get errors => _errors;

  /// Validate the [instance] against the this validator's schema
  bool validate(dynamic instance, [bool reportMultipleErrors = false]) {
    // _logger.info('Validating ${instance.runtimeType}:$instance on ${_rootSchema}'); TODO: re-add logger

    _reportMultipleErrors = reportMultipleErrors;
    _errors = [];
    if (!_reportMultipleErrors) {
      try {
        _validate(_rootSchema, instance);
        return true;
      } on FormatException {
        return false;
      } catch (e) {
        // _logger.shout('Unexpected Exception: $e'); TODO: re-add logger
        return false;
      }
    }

    _validate(_rootSchema, instance);
    return _errors.length == 0;
  }

  static bool _typeMatch(SchemaType type, dynamic instance) {
    switch (type) {
      case SchemaType.OBJECT:
        return instance is Map;
      case SchemaType.STRING:
        return instance is String;
      case SchemaType.INTEGER:
        return instance is int;
      case SchemaType.NUMBER:
        return instance is num;
      case SchemaType.ARRAY:
        return instance is List;
      case SchemaType.BOOLEAN:
        return instance is bool;
      case SchemaType.NULL:
        return instance == null;
    }
    return false;
  }

  void _numberValidation(JsonSchema schema, num n) {
    final maximum = schema.maximum;
    final minimum = schema.minimum;
    if (maximum != null) {
      if (schema.exclusiveMaximum) {
        if (n >= maximum) {
          _err('${schema.path}: maximum exceeded ($n >= $maximum)');
        }
      } else {
        if (n > maximum) {
          _err('${schema.path}: maximum exceeded ($n > $maximum)');
        }
      }
    } else if (minimum != null) {
      if (schema.exclusiveMinimum) {
        if (n <= minimum) {
          _err('${schema.path}: minimum violated ($n <= $minimum)');
        }
      } else {
        if (n < minimum) {
          _err('${schema.path}: minimum violated ($n < $minimum)');
        }
      }
    }

    final multipleOf = schema.multipleOf;
    if (multipleOf != null) {
      if (multipleOf is int && n is int) {
        if (0 != n % multipleOf) {
          _err('${schema.path}: multipleOf violated ($n % $multipleOf)');
        }
      } else {
        final double result = n / multipleOf;
        if (result.truncate() != result) {
          _err('${schema.path}: multipleOf violated ($n % $multipleOf)');
        }
      }
    }
  }

  void _typeValidation(JsonSchema schema, dynamic instance) {
    final typeList = schema.schemaTypeList;
    if (typeList != null && typeList.length > 0) {
      if (!typeList.any((type) => _typeMatch(type, instance))) {
        _err('${schema.path}: type: wanted ${typeList} got $instance');
      }
    }
  }

  void _enumValidation(JsonSchema schema, dynamic instance) {
    final enumValues = schema.enumValues;
    if (enumValues.length > 0) {
      try {
        enumValues.singleWhere((v) => JsonSchemaUtils.jsonEqual(instance, v));
      } on StateError {
        _err('${schema.path}: enum violated ${instance}');
      }
    }
  }

  void _stringValidation(JsonSchema schema, String instance) {
    final actual = instance.runes.length;
    final minLength = schema.minLength;
    final maxLength = schema.maxLength;
    if (maxLength is int && actual > maxLength) {
      _err('${schema.path}: maxLength exceeded ($instance vs $maxLength)');
    } else if (minLength is int && actual < minLength) {
      _err('${schema.path}: minLength violated ($instance vs $minLength)');
    }
    final pattern = schema.pattern;
    if (pattern != null && !pattern.hasMatch(instance)) {
      _err('${schema.path}: pattern violated ($instance vs $pattern)');
    }
  }

  void _itemsValidation(JsonSchema schema, List instance) {
    final int actual = instance.length;

    final singleSchema = schema.items;
    if (singleSchema != null) {
      instance.forEach((item) => _validate(singleSchema, item));
    } else {
      final items = schema.itemsList;
      final additionalItems = schema.additionalItems;

      if (items != null) {
        final expected = items.length;
        final end = min(expected, actual);
        for (int i = 0; i < end; i++) {
          assert(items[i] != null);
          _validate(items[i], instance[i]);
        }
        if (additionalItems is JsonSchema) {
          for (int i = end; i < actual; i++) {
            _validate(additionalItems, instance[i]);
          }
        } else if (additionalItems is bool) {
          if (!additionalItems && actual > end) {
            _err('${schema.path}: additionalItems false');
          }
        }
      }
    }

    final maxItems = schema.maxItems;
    final minItems = schema.minItems;
    if (maxItems is int && actual > maxItems) {
      _err('${schema.path}: maxItems exceeded ($actual vs $maxItems)');
    } else if (schema.minItems is int && actual < schema.minItems) {
      _err('${schema.path}: minItems violated ($actual vs $minItems)');
    }

    if (schema.uniqueItems) {
      final end = instance.length;
      final penultimate = end - 1;
      for (int i = 0; i < penultimate; i++) {
        for (int j = i + 1; j < end; j++) {
          if (JsonSchemaUtils.jsonEqual(instance[i], instance[j])) {
            _err('${schema.path}: uniqueItems violated: $instance [$i]==[$j]');
          }
        }
      }
    }
  }

  void _validateAllOf(JsonSchema schema, instance) {
    final List<JsonSchema> schemas = schema.allOf;
    final errorsSoFar = _errors.length;
    int i = 0;
    schemas.every((s) {
      assert(s != null);
      _validate(s, instance);
      final bool valid = _errors.length == errorsSoFar;
      if (!valid) {
        _err('${s.path}/$i: allOf violated ${instance}');
      }
      i++;
      return valid;
    });
  }

  void _validateAnyOf(JsonSchema schema, instance) {
    if (!schema.anyOf.any((s) => new Validator(s).validate(instance))) {
      _err('${schema.path}/anyOf: anyOf violated ($instance, ${schema.anyOf})');
    }
  }

  void _validateOneOf(JsonSchema schema, instance) {
    try {
      schema.oneOf.singleWhere((s) => new Validator(s).validate(instance));
    } on StateError catch (notOneOf) {
      _err('${schema.path}/oneOf: violated ${notOneOf.message}');
    }
  }

  void _validateNot(JsonSchema schema, instance) {
    if (new Validator(schema.notSchema).validate(instance)) {
      _err('${schema.notSchema.path}: not violated');
    }
  }

  void _validateFormat(JsonSchema schema, instance) {
    switch (schema.format) {
      case 'date-time':
        {
          try {
            DateTime.parse(instance);
          } catch (e) {
            _err('"date-time" format not accepted $instance');
          }
        }
        break;
      case 'uri':
        {
          final isValid = defaultValidators.uriValidator ?? (_) => false;

          if (!isValid(instance)) {
            _err('"uri" format not accepted $instance');
          }
        }
        break;
      case 'email':
        {
          final isValid = defaultValidators.emailValidator ?? (_) => false;

          if (!isValid(instance)) {
            _err('"email" format not accepted $instance');
          }
        }
        break;
      case 'ipv4':
        {
          if (JsonSchemaValidationRegexes.ipv4.firstMatch(instance) == null) {
            _err('"ipv4" format not accepted $instance');
          }
        }
        break;
      case 'ipv6':
        {
          if (JsonSchemaValidationRegexes.ipv6.firstMatch(instance) == null) {
            _err('ipv6" format not accepted $instance');
          }
        }
        break;
      case 'hostname':
        {
          if (JsonSchemaValidationRegexes.hostname.firstMatch(instance) == null) {
            _err('"hostname" format not accepted $instance');
          }
        }
        break;
      default:
        {
          _err('${schema.format} not supported as format');
        }
    }
  }

  void _objectPropertyValidation(JsonSchema schema, Map instance) {
    final propMustValidate = schema.additionalProperties != null && !schema.additionalProperties;

    instance.forEach((k, v) {
      bool propCovered = false;
      final JsonSchema propSchema = schema.properties[k];
      if (propSchema != null) {
        assert(propSchema != null);
        _validate(propSchema, v);
        propCovered = true;
      }

      schema.patternProperties.forEach((regex, patternSchema) {
        if (regex.hasMatch(k)) {
          assert(patternSchema != null);
          _validate(patternSchema, v);
          propCovered = true;
        }
      });

      if (!propCovered) {
        if (schema.additionalPropertiesSchema != null) {
          _validate(schema.additionalPropertiesSchema, v);
        } else if (propMustValidate) {
          _err('${schema.path}: unallowed additional property $k');
        }
      }
    });
  }

  void _propertyDependenciesValidation(JsonSchema schema, Map instance) {
    schema.propertyDependencies.forEach((k, dependencies) {
      if (instance.containsKey(k)) {
        if (!dependencies.every((prop) => instance.containsKey(prop))) {
          _err('${schema.path}: prop $k => $dependencies required');
        }
      }
    });
  }

  void _schemaDependenciesValidation(JsonSchema schema, Map instance) {
    schema.schemaDependencies.forEach((k, otherSchema) {
      if (instance.containsKey(k)) {
        if (!new Validator(otherSchema).validate(instance)) {
          _err('${otherSchema.path}: prop $k violated schema dependency');
        }
      }
    });
  }

  void _objectValidation(JsonSchema schema, Map instance) {
    final numProps = instance.length;
    final minProps = schema.minProperties;
    final maxProps = schema.maxProperties;
    if (numProps < minProps) {
      _err('${schema.path}: minProperties violated (${numProps} < ${minProps})');
    } else if (maxProps != null && numProps > maxProps) {
      _err('${schema.path}: maxProperties violated (${numProps} > ${maxProps})');
    }
    if (schema.requiredProperties != null) {
      schema.requiredProperties.forEach((prop) {
        if (!instance.containsKey(prop)) {
          _err('${schema.path}: required prop missing: ${prop} from $instance');
        }
      });
    }
    _objectPropertyValidation(schema, instance);

    if (schema.propertyDependencies != null) _propertyDependenciesValidation(schema, instance);

    if (schema.schemaDependencies != null) _schemaDependenciesValidation(schema, instance);
  }

  void _validate(JsonSchema schema, dynamic instance) {
    /// If the [JsonSchema] is a bool, always return this value
    if (schema.schemaBool != null) {
      if (schema.schemaBool == false) {
        _err('${schema.path}: schema is a boolean == false, this schema will never validate. Instance: $instance');
      }
      return;
    }

    /// If the [JsonSchema] being validated is a ref, pull the ref
    /// from the [refMap] instead.
    if (schema.ref != null) {
      final String path = schema.root.endPath(schema.ref);
      schema = schema.root.refMap[path];
    }
    _typeValidation(schema, instance);
    _enumValidation(schema, instance);
    if (instance is List) _itemsValidation(schema, instance);
    if (instance is String) _stringValidation(schema, instance);
    if (instance is num) _numberValidation(schema, instance);
    if (schema.allOf.length > 0) _validateAllOf(schema, instance);
    if (schema.anyOf.length > 0) _validateAnyOf(schema, instance);
    if (schema.oneOf.length > 0) _validateOneOf(schema, instance);
    if (schema.notSchema != null) _validateNot(schema, instance);
    if (schema.format != null) _validateFormat(schema, instance);
    if (instance is Map) _objectValidation(schema, instance);
  }

  void _err(String msg) {
    // _logger.warning(msg); TODO: re-add logger
    _errors.add(msg);
    if (!_reportMultipleErrors) throw new FormatException(msg);
  }

  JsonSchema _rootSchema;
  List<String> _errors = [];
  bool _reportMultipleErrors;
}
