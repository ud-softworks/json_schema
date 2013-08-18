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
        class_('invalid_schema')
        ..doc = 'Exception indicating the schema is not conformant'
        ..implement = ['Exception'],
        class_('i_schema')
        ..isAbstract = true,
        class_('numeric_schema')
        ..defaultMemberAccess = IA
        ..implement = [ 'ISchema' ],
        class_('string_schema')
        ..defaultMemberAccess = IA
        ..implement = [ 'ISchema' ],
        class_('array_schema')
        ..defaultMemberAccess = IA
        ..implement = [ 'ISchema' ],
        class_('object_schema')
        ..defaultMemberAccess = IA
        ..implement = [ 'ISchema' ],
        class_('schema')
        ..defaultMemberAccess = IA
        ..implement = [ 'ISchema' ]
        ..ctorCustoms = [ 'fromString', 'fromMap' ]
        ..doc = 'Constructed with a json schema, either as string or Map'
        ..members = [
          member('schema_text')
          ..doc = 'Text defining the schema for validation'
          ..ctors = [ 'fromString' ],
          member('schema_map')
          ..type = 'Map'
          ..classInit = '{}'
          ..ctors = [ 'fromMap' ],
          member('path')
          ..ctorInit = "'#'"
          ..ctorsOpt = [ 'fromMap', 'fromString' ],
          member('id'),
          member('description'),
          member('schema_type')
          ..type = 'SchemaType',
          member('property_schemas')
          ..type = 'Map<String,Schema>'
          ..classInit = '{}',
          member('all_of')
          ..type = 'List<Schema>',
          member('any_of')
          ..type = 'List<Schema>',
          member('one_of')
          ..type = 'List<Schema>',
          member('item_schema')
          ..type = 'Schema',
          member('required_properties')
          ..type = 'List<String>',
          member('default_value')
          ..type = 'dynamic',

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

        ],
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

