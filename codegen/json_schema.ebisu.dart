import "dart:io";
import "package:path/path.dart" as path;
import "package:ebisu/ebisu_dart_meta.dart";

String _topDir;

void main() {
  Options options = new Options();
  String here = path.absolute(options.script);
  _topDir = path.dirname(path.dirname(here));
  System ebisu = system('json_schema')
    ..rootPath = '$_topDir'
    ..doc = 'Json Schema related functionality'
    ..libraries = [
      library('json_schema')
      ..doc = 'Support for validating json instances against a json schema'
      ..includeLogger = true
      ..variables = [
      ]
      ..enums = [
        enum_('schema_type')
        ..isSnakeString = true
        ..hasCustom = true
        ..values = [
          id('array'), id('boolean'), id('integer'),
          id('number'), id('null'), id('object'),
          id('string')
        ]
      ]
      ..imports = [
        'io',
        'math',
        '"dart:json" as JSON',
        '"package:path/path.dart" as PATH',
        'async',
      ]
      ..parts = [
        part('json_schema')
        ..classes = [
          class_('schema')
          ..defaultMemberAccess = RO
          ..ctorCustoms = [ '_fromRootMap', '_fromMap' ]
          ..doc = '''
Constructed with a json schema, either as string or Map. Validation of
the schema itself is done on construction. Any errors in the schema
result in a FormatException being thrown.
'''
          ..members = [
            member('root')
            ..type = 'Schema'
            ..ctors = [ '_fromMap' ],
            member('schema_map')
            ..type = 'dynamic'
            ..classInit = '{}'
            ..ctors = [ '_fromRootMap', '_fromMap' ],
            member('path')
            ..ctorInit = "'#'"
            ..ctors = [ '_fromMap' ],

            member('multiple_of')
            ..type = 'num',
            member('maximum')
            ..type = 'num',
            member('exclusive_maximum')
            ..type = 'bool'
            ..access = IA,
            member('minimum')
            ..type = 'num',
            member('exclusive_minimum')
            ..type = 'bool'
            ..access = IA,
            member('max_length')
            ..type = 'int',
            member('min_length')
            ..type = 'int',
            member('pattern')
            ..type = 'RegExp',

            // Validation keywords for any instance
            member('enum_values')
            ..type = 'List',
            member('all_of')
            ..type = 'List<Schema>',
            member('any_of')
            ..type = 'List<Schema>',
            member('one_of')
            ..type = 'List<Schema>',
            member('not_schema')
            ..type = 'Schema',
            member('definitions')
            ..type = 'Map<String,Schema>',

            // Meta-data
            member('id')
            ..type = 'Uri',
            member('ref'),
            member('description'),
            member('title'),

            member('schema_type_list')
            ..type = 'List<SchemaType>',
            member('items')
            ..doc = 'To match all items to a schema'
            ..type = 'Schema',
            member('items_list')
            ..doc = 'To match each item in array to a schema'
            ..type = 'List<Schema>',
            member('additional_items')
            ..type = 'dynamic',
            member('max_items')
            ..type = 'int',
            member('min_items')
            ..type = 'int',
            member('unique_items')
            ..type = 'bool'
            ..classInit = 'false',

            member('required_properties')
            ..type = 'List<String>',
            member('max_properties')
            ..type = 'int',
            member('min_properties')
            ..type = 'int'
            ..classInit = '0',
            member('properties')
            ..type = 'Map<String,Schema>'
            ..classInit = '{}',
            member('additional_properties')
            ..type = 'bool',
            member('additional_properties_schema')
            ..type = 'Schema',
            member('pattern_properties')
            ..type = 'Map<RegExp,Schema>'
            ..classInit = '{}',

            member('schema_dependencies')
            ..type = 'Map<String,Schema>',
            member('property_dependencies')
            ..type = 'Map<String,List<String>>',

            member('default_value')
            ..type = 'dynamic',

            member('ref_map')
            ..doc = 'Map of path to schema object'
            ..type = 'Map<String,Schema>'
            ..access = IA
            ..classInit = '{}',
            member('schema_refs')
            ..doc = 'For schemas with \$ref maps path of schema to \$ref path'
            ..type = 'Map<String,String>'
            ..access = IA
            ..classInit = '{}',
            member('schema_assignments')
            ..doc = 'Assignments to call for resolution upon end of parse'
            ..type = 'List'
            ..classInit = '[]'
            ..access = IA,
            member('free_form_map')
            ..doc = 'Maps any non-key top level property to its original value'
            ..type = 'Map<String,dynamic>'
            ..classInit = '{}'
            ..access = IA,
          ]
        ],
        part('json_validator')
        ..classes = [
          class_('validator')
          ..defaultMemberAccess = IA
          ..ctorCustoms = [ '' ]
          ..doc = 'Initialized with schema, validates instances against it'
          ..members = [
            member('root_schema')
            ..type = 'Schema'
            ..ctors = [''],
            member('errors')
            ..type = 'List<String>'
            ..classInit = '[]',
            member('report_multiple_errors')
            ..type = 'bool',
          ],
        ]
      ]
    ];
  ebisu.generate();
}

