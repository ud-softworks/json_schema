// This test suite verifies that validation errors report correct values for
// instance & schema paths.

import 'package:json_schema/json_schema.dart';
import 'package:test/test.dart';

// TODO: test nested $refs
// https://github.com/epoberezkin/ajv/issues/876
// https://github.com/epoberezkin/ajv/issues/512

JsonSchema createObjectSchema(Map<String, dynamic> nestedSchema) {
  return JsonSchema.createSchema({
    'properties': {
      'someKey': nestedSchema
    }
  });
}

    // _typeValidation(schema, instance);
    // _constValidation(schema, instance);
    // _enumValidation(schema, instance);

    // if (instance.data is String) _stringValidation(schema, instance);
    // - maxLength
    // - minLength
    // - pattern

    // if (instance.data is num) _numberValidation(schema, instance);
    // - maximum
    // - minimum
    // - exclusiveMaximum
    // - exclusiveMinimum
    // - multipleOf

    // if (instance.data is List) _itemsValidation(schema, instance);
    // - single schema
    // - multiple schemas
    // - additional items
    // - additional items bool

    // if (schema.allOf.length > 0) _validateAllOf(schema, instance);
    // if (schema.anyOf.length > 0) _validateAnyOf(schema, instance);
// if (schema.oneOf.length > 0) _validateOneOf(schema, instance);
// if (schema.notSchema != null) _validateNot(schema, instance);
// if (schema.format != null) _validateFormat(schema, instance);
// if (instance.data is Map) _objectValidation(schema, instance);

void main() {
  group('validation error', () {
    test('type', () {
      final schema = createObjectSchema({"type": "string"});
      final errors = schema.validateWithErrors({'someKey': 1});

      expect(errors[0].instancePath, '/someKey');
      expect(errors[0].schemaPath, '/properties/someKey');
      expect(errors[0].message, contains('type'));
    });

    test('const', () {
      final schema = createObjectSchema({'const': 'foo'});
      final errors = schema.validateWithErrors({'someKey': 'bar'});

      expect(errors[0].instancePath, '/someKey');
      expect(errors[0].schemaPath, '/properties/someKey');
      expect(errors[0].message, contains('const'));
    });

    test('enum', () {
      final schema = createObjectSchema({'enum': [1, 2, 3]});
      final errors = schema.validateWithErrors({'someKey': 4});

      expect(errors[0].instancePath, '/someKey');
      expect(errors[0].schemaPath, '/properties/someKey');
      expect(errors[0].message, contains('enum'));
    });

    group('string', () {
      final schema = createObjectSchema({
        'minLength': 3,
        'maxLength': 5,
        'pattern': '^a.*\$'
      });

      test('minLength', () {
        final errors = schema.validateWithErrors({'someKey': 'ab'});

        expect(errors[0].instancePath, '/someKey');
        expect(errors[0].schemaPath, '/properties/someKey');
        expect(errors[0].message, contains('minLength'));
      });

      test('maxLength', () {
        final errors = schema.validateWithErrors({'someKey': 'abcdef'});

        expect(errors[0].instancePath, '/someKey');
        expect(errors[0].schemaPath, '/properties/someKey');
        expect(errors[0].message, contains('maxLength'));
      });

      test('pattern', () {
        final errors = schema.validateWithErrors({'someKey': 'bye'});

        expect(errors[0].instancePath, '/someKey');
        expect(errors[0].schemaPath, '/properties/someKey');
        expect(errors[0].message, contains('pattern'));
      });
    });

    group('number', () {
      final schema =createObjectSchema({
        'properties': {
          'nonexclusive': {
            'maximum': 5.0,
            'minimum': 3.0,
          },
          'exclusive': {
            'exclusiveMaximum': 5.0,
            'exclusiveMinimum': 3.0
          },
          'multiple': {'multipleOf': 2}
        }
      });

      test('maximum', () {
        final errors = schema.validateWithErrors({'someKey': {'nonexclusive': 5.1}});

        expect(errors[0].instancePath, '/someKey/nonexclusive');
        expect(errors[0].schemaPath, '/properties/someKey/properties/nonexclusive');
        expect(errors[0].message, contains('maximum'));
      });

      test('minimum', () {
        final errors = schema.validateWithErrors({'someKey': {'nonexclusive': 2.9}});

        expect(errors[0].instancePath, '/someKey/nonexclusive');
        expect(errors[0].schemaPath, '/properties/someKey/properties/nonexclusive');
        expect(errors[0].message, contains('minimum'));
      });

      test('exclusiveMaximum', () {
        final errors = schema.validateWithErrors({'someKey': {'exclusive': 5.0}});

        expect(errors[0].instancePath, '/someKey/exclusive');
        expect(errors[0].schemaPath, '/properties/someKey/properties/exclusive');
        expect(errors[0].message, contains('exclusiveMaximum'));
      });

      test('exclusiveMinimum', () {
        final errors = schema.validateWithErrors({'someKey': {'exclusive': 3.0}});

        expect(errors[0].instancePath, '/someKey/exclusive');
        expect(errors[0].schemaPath, '/properties/someKey/properties/exclusive');
        expect(errors[0].message, contains('exclusiveMinimum'));
      });

      test('multipleOf', () {
        final errors = schema.validateWithErrors({'someKey': {'multiple': 7}});

        expect(errors[0].instancePath, '/someKey/multiple');
        expect(errors[0].schemaPath, '/properties/someKey/properties/multiple');
        expect(errors[0].message, contains('multipleOf'));
      });
    });

    test('items with the same schema', () {
      final schema = createObjectSchema({'items': {'type': 'integer'}});
      final errors = schema.validateWithErrors({'someKey': [1, 2, 'foo']});

      expect(errors[0].instancePath, '/someKey/2');
      expect(errors[0].schemaPath, '/properties/someKey/items');
      expect(errors[0].message, contains('type'));
   });

    test('items with an array of schemas', () {
      final schema = createObjectSchema({'items': [
        {'type': 'integer'},
        {'type': 'string'}
      ]});
      final errors = schema.validateWithErrors({'someKey': ['foo', 'bar']});

      expect(errors[0].instancePath, '/someKey/0');
      expect(errors[0].schemaPath, '/properties/someKey/items/0');
      expect(errors[0].message, contains('type'));
    });

    test('defined items with type checking of additional items', () {

      final schema = createObjectSchema({
        'items': [{'type': 'string'}, {'type': 'string'}],
        'additionalItems': {'type': 'integer'}
      });
      final errors = schema.validateWithErrors({'someKey': ['foo', 'bar', 'baz']});

      expect(errors[0].instancePath, '/someKey/2');
      expect(errors[0].schemaPath, '/properties/someKey/additionalItems');
      expect(errors[0].message, contains('type'));
    });

    test('defined items with no additional items allowed', () {

      final schema = createObjectSchema({
        'items': [{'type': 'string'}, {'type': 'string'}],
        'additionalItems': false
      });
      final errors = schema.validateWithErrors({'someKey': ['foo', 'bar', 'baz']});

      expect(errors[0].instancePath, '/someKey');
      expect(errors[0].schemaPath, '/properties/someKey/additionalItems');
      expect(errors[0].message, contains('additionalItems'));
    });

    test('simple allOf schema', () {
      final schema = createObjectSchema({
        "allOf": [
          { "type": "string" },
          { "maxLength": 5 }
        ]
      });

      final errors = schema.validateWithErrors({'someKey': 'a long string'});

      expect(errors[0].instancePath, '/someKey');
      expect(errors[0].schemaPath, '/properties/someKey/allOf/1');
      expect(errors[0].message, contains('maxLength'));
    });

    test('allOf with an additional base schema', () {
      final schema = createObjectSchema({
        "properties": {"bar": {"type": "integer"}},
        "required": ["bar"],
        "allOf" : [
          {
            "properties": {
              "foo": {"type": "string"}
            },
            "required": ["foo"]
          },
          {
            "properties": {
              "baz": {"type": "null"}
            },
            "required": ["baz"]
          }
        ]
      });

      final errors = schema.validateWithErrors({'someKey': {'foo': 'string', 'bar': 1}});

      expect(errors[0].instancePath, '/someKey');
      expect(errors[0].schemaPath, '/properties/someKey/allOf/1/required');
      expect(errors[0].message, contains('required'));
    });

    test('anyOf', () {
      final schema = createObjectSchema({
        "anyOf": [
          {"type": "integer"},
          {"minimum": 2}
        ]
      });

      final errors = schema.validateWithErrors({'someKey': 1.5});

      expect(errors[0].instancePath, '/someKey');
      expect(errors[0].schemaPath, '/properties/someKey/anyOf/0');
      expect(errors[0].message, contains('type'));
    });
  });
}