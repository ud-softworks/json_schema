import "dart:io";
import "package:pathos/path.dart" as path;
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
        '"dart:json" as JSON', 
        'package:plus/pprint.dart',
      ]
      ..classes = [
        class_('schema')
        ..defaultMemberAccess = IA
        ..ctorCustoms = [ 'fromString', 'fromMap' ]
        ..doc = 'Constructed with a json schema, either as string or Map'
        ..members = [
          member('schema_text')
          ..doc = 'Text defining the schema for validation'
          ..ctors = [ 'fromString' ],
          member('schema_map')
          ..type = 'dynamic'
          ..classInit = '{}'
          ..ctors = [ 'fromMap' ],
          member('path')
          ..ctorInit = "'#'"
          ..ctorsOpt = [ 'fromMap', 'fromString' ],

          member('multiple_of')
          ..type = 'num',
          member('maximum')
          ..type = 'num',
          member('exclusive_maximum')
          ..type = 'bool',
          member('minimum')
          ..type = 'num',
          member('exclusive_minimum')
          ..type = 'bool',
          member('max_length')
          ..type = 'int',
          member('min_length')
          ..type = 'int',
          member('pattern')
          ..type = 'RegExp',
          
          // Validation keywords for any instance
          member('enum_values')
          ..type = 'List',
          member('schema_type')
          ..type = 'SchemaType',
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
          member('id'),
          member('description'),
          member('title'),

          member('schema_type_list')
          ..type = 'List<SchemaType>',
          member('properties')
          ..type = 'Map<String,Schema>'
          ..classInit = '{}',
          member('items')
          ..type = 'Schema',
          member('items_list')
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
          ..type = 'int',
          member('additional_properties')
          ..type = 'bool',
          member('additional_properties_schema')
          ..type = 'Schema',
          member('pattern_properties')
          ..type = 'Map',

          member('schema_dependencies')
          ..type = 'Map<String,Schema>',
          member('property_dependencies')
          ..type = 'List<String>',

          member('default_value')
          ..type = 'dynamic',

        ],
        class_('numeric_schema')
        ..defaultMemberAccess = IA
        ..extend = 'Schema',
        class_('string_schema')
        ..defaultMemberAccess = IA
        ..extend = 'Schema',
        class_('array_schema')
        ..defaultMemberAccess = IA
        ..extend = 'Schema',
        class_('object_schema')
        ..defaultMemberAccess = IA
        ..extend = 'Schema',
        class_('validator')
        ..defaultMemberAccess = IA
        ..doc = 'Initialized with schema and will validate json instances against it'
        ..members = [
          member('schema')
          ..type = 'Schema'
          ..ctors = ['']
        ]
      ]
    
    ];
  ebisu.generate();
}

