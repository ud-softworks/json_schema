#!/usr/bin/env dart
/// 
/// Usage: schemadot --in-uri INPUT_JSON_URI --out-file OUTPUT_FILE
/// 
/// Given an input uri [in-uri] processes content of uri as
/// json schema and generates input file for Graphviz dot
/// program. If [out-file] provided, output is written to 
/// to the file, otherwise written to stdout.
/// 

import 'package:json_schema/json_schema.dart';
import 'dart:json' as JSON;
import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';

//! The parser for this script
ArgParser _parser;

//! The comment and usage associated with this script
void _usage() { 
  print('''

Usage: schemadot --in-uri INPUT_JSON_URI --out-file OUTPUT_FILE

Given an input uri [in-uri] processes content of uri as
json schema and generates input file for Graphviz dot
program. If [out-file] provided, output is written to 
to the file, otherwise written to stdout.

''');
  print(_parser.getUsage());
}

//! Method to parse command line options.
//! The result is a map containing all options, including positional options
Map _parseArgs() { 
  ArgResults argResults;
  Map result = { };
  List remaining = [];

  _parser = new ArgParser();
  try { 
    /// Fill in expectations of the parser
    _parser.addOption('in-uri', 
      defaultsTo: null,
      allowMultiple: false,
      abbr: 'i',
      allowed: null);
    _parser.addOption('out-file', 
      defaultsTo: null,
      allowMultiple: false,
      abbr: 'o',
      allowed: null);

    /// Parse the command line options (excluding the script)
    var arguments = new Options().arguments;
    argResults = _parser.parse(arguments);
    argResults.options.forEach((opt) { 
      result[opt] = argResults[opt];
    });
    
    return { 'options': result, 'rest': remaining };

  } catch(e) { 
    _usage();
    throw e;
  }
}

final _logger = new Logger("schemadot");

main() { 
  Logger.root.onRecord.listen(new PrintHandler());
  Logger.root.level = Level.INFO;
  Map argResults = _parseArgs();
  Map options = argResults['options'];
  List positionals = argResults['rest'];

  try { 
    if(options["in-uri"] == null)
      throw new ArgumentError("option: in-uri is required");

  } on ArgumentError catch(e) { 
    print(e);
    _usage();
  }
  // custom <schemadot main>

  Logger.root.level = Level.SHOUT;
  Completer completer = new Completer();
  Uri uri = Uri.parse(options['in-uri']);
  if(uri.scheme == 'http') {
    new HttpClient()
      .getUrl(uri)
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) =>
          response
          .transform(new StringDecoder())
          .join())
      .then((text) {
        completer.complete(text);
      });
  } else {
    File target = new File(uri.toString());
    if(target.existsSync()) {
      completer.complete(target.readAsStringSync());
    }
  }

  completer.future.then((schemaText) {
    Future schema = Schema.createSchema(JSON.parse(schemaText));
    schema.then((schema) {
      String nodes = new SchemaNode(schema).nodes;
      String dot = '''
digraph G {
  fontname = "Bitstream Vera Sans"
  fontsize = 8

  node [
    fontname = "Courier"
    fontsize = 8
    shape = "plaintext"
  ]

  edge [
    fontname = "Bitstream Vera Sans"
    fontsize = 8
  ]

${nodes}


}
''';

      if(options['out-file'] != null) {
        new File(options['out-file']).writeAsStringSync(dot);
      } else {
        print(dot);
      }

    });


  });


  // end <schemadot main>
  
}

// custom <schemadot global>

class SchemaNode {
  
  Schema schema;
  List<String> links;
  
  SchemaNode(Schema this.schema, [ this.links ]) {
    if(links==null) links=[];
  }

  static bool schemaShown(Schema schema) =>
    schema.properties.length > 0 || 
    schema.definitions.length > 0 ||
    schema.anyOf.length > 0 ||
    schema.oneOf.length > 0 ||
    schema.allOf.length > 0 ||
    schema.enumValues.length > 0 ||
    schema.additionalPropertiesSchema != null ||
    schema.minimum != null ||
    schema.maximum != null ||
    schema.ref != null;

  String get nodes {
    List lines = schema.refMap.values
    .where((schema) => schemaShown(schema))
    .map((schema) => new SchemaNode(schema, links).node)
    .toList();
    lines.addAll(links.map((link) => "$link;"));

    schema
    .paths
    .where((path) => path != schema.resolvePath(path).path)
    .forEach((path) {
      print("Found referring schema ${path} => ${schema.resolvePath(path).path}");
    });

    return lines.join('\n');
  }

  String get node {
    var data = 
    [ '"${schema.path}" [']
    ..add(label.join('\n'))
    ..add(']');
    return data.join('\n');
  }

  static dynamic schemaType(Schema schema) {
    dynamic result;
    if(schema.schemaTypeList == null) {
      if(schema.oneOf.length > 0) {
        result = "oneOf:${schema.oneOf.map((schema) => schemaType(schema)).toList()}";
      } else if(schema.anyOf.length > 0) {
        result = "anyOf:${schema.anyOf.map((schema) => schemaType(schema)).toList()}";
      } else if(schema.allOf.length > 0) {
        result = "allOf:${schema.allOf.map((schema) => schemaType(schema)).toList()}";
      } else if(schema.defaultValue != null) {
        result = "default=${schema.defaultValue}";
      } else if(schema.ref != null) {
        result = "ref=${schema.ref}";
      } else if(schema.enumValues != null) {
        result = "enum=${schema.enumValues}";
      } else if(schema.schemaMap.length == 0) {
        result = "{}";
      } else {
        result = "$schema";
      }
    } else {
      result = schema.schemaTypeList;
    }
    if((result is List) && result.length == 0) result = {};
    if(result == null) result = {};
    return result;
  }

  List<String> get label {
    return
    [ 'label =<' ]
    ..add('<table border="0" cellborder="0" cellpadding="1" bgcolor="white">')
    ..add(wrap(schema.path, port : "@path"))
    ..add(wrap(title))
    ..add(wrap(description))
    ..addAll(definitionEntries)
    ..addAll(propertyEntries)
    ..addAll(additionalPropertiesSchema)
    ..addAll(propertyDependencies)
    ..addAll(schemaDependencies)
    ..addAll(minimum)
    ..addAll(maximum)
    ..addAll(defaultValue)
    ..addAll(anyOf)
    ..addAll(oneOf)
    ..addAll(allOf)
    ..addAll(enumEntries)
    ..add('</table>')
    ..add('>');    
  }

  List<String> get defaultValue {
    List<String> result = [];
    if(schema.defaultValue != null) {
      result.add(wrapRowDistinct('default', "${schema.defaultValue}"));
    }
    return result;
  }

  List<String> get minimum {
    List<String> result = [];
    if(schema.minimum != null) {
      result.add(wrapRowDistinct('minimum', "${schema.minimum}"));
    }
    return result;
  }

  List<String> get maximum {
    List<String> result = [];
    if(schema.maximum != null) {
      result.add(wrapRowDistinct('maximum', "${schema.maximum}"));
    }
    return result;
  }

  List<String> get multipleOf {
    List<String> result = [];
    if(schema.multipleOf != null) {
      result.add(wrapRowDistinct('multipleOf', "${schema.multipleOf}"));
    }
    return result;
  }

  List<String> get enumEntries {
    List<String> enumValues = [];
    if(schema.enumValues.length > 0) {
      enumValues.add(wrap('Enum Values', color : 'beige'));
      schema.enumValues.forEach((value) {
        enumValues.add(wrap("$value", color:'grey'));
      });
    }
    return enumValues;
  }

  List<String> get anyOf {
    List<String> anyOf = [];
    if(schema.anyOf.length > 0) {
      anyOf.add(wrap('Any Of', color : 'beige'));
      int i=0;
      schema.anyOf.forEach((anyOfSchema) {
        String port = "${i++}";
        makeSchemaLink(port, schema, anyOfSchema);
        anyOf.add(wrap("${schemaType(anyOfSchema)}", color:'grey', port:port));
      });
    }
    return anyOf;
  }

  List<String> get oneOf {
    List<String> oneOf = [];
    if(schema.oneOf.length > 0) {
      oneOf.add(wrap('One Of', color : 'beige'));
      int i=0;
      schema.oneOf.forEach((oneOfSchema) {
        String port = "${i++}";
        makeSchemaLink(port, schema, oneOfSchema);
        oneOf.add(wrap("${schemaType(oneOfSchema)}", color:'grey', port:port));
      });
    }
    return oneOf;
  }

  List<String> get allOf {
    List<String> allOf = [];
    if(schema.allOf.length > 0) {
      allOf.add(wrap('All Of', color : 'beige'));
      int i=0;
      schema.allOf.forEach((allOfSchema) {
        String port = "${i++}";
        makeSchemaLink(port, schema, allOfSchema);
        allOf.add(wrap("${schemaType(allOfSchema)}", color:'grey', port:port));
      });
    }
    return allOf;
  }

  List<String> get propertyDependencies {
    List<String> result = [];
    if(schema.propertyDependencies.length > 0) {
      result.add(wrap('Property Dependencies'));
      schema.propertyDependencies.forEach((key, val) {
        result.add(wrapRowDistinct(key, val.toString()));
      });
    }
    return result;
  }

  List<String> get schemaDependencies {
    List<String> result = [];
    if(schema.schemaDependencies.length > 0) {
      result.add('Property Dependencies');
      schema.propertyDependencies.forEach((key, val) {
        result.add(wrapRowDistinct(key, val.path));
      });
    }
    return result;
  }

  makeSchemaPort(String port, Schema schema) =>
    '"${schema.path}":"$port"';

  makeSchemaLink(String port, Schema src, Schema target) {
    if(schemaShown(target))
      links.add('${makeSchemaPort(port, src)} -> ${makeSchemaPort("@path", target)}');
  }

  List<String> get additionalPropertiesSchema {
    List<String> result = [];
    Schema other = schema.additionalPropertiesSchema;
    if(other != null) {
      result.add(wrap('Additional Properties', color:'lemonchiffon'));
      String port = "mustBe";
      makeSchemaLink(port, schema, other);
      result.add(wrapRowDistinct(
            'Must Be: ', 
            abbreviatedString(schemaType(other).toString(), 30), 
            port));
    }
    return result;
  }
  
  List<String> get propertyEntries {
    List<String> props = [];
    if(schema.properties.length > 0) {
      props.add(wrap('Properties'));
      schema.properties.forEach((prop, propertySchema) {
        String port = "@$prop";
        if(schemaShown(propertySchema)) {
          makeSchemaLink(port, schema, propertySchema);
        } else if(propertySchema.items is Schema && 
            schemaShown(propertySchema.items)) {
          makeSchemaLink(port, schema, propertySchema.items);
        }
        props.add(
          wrapRowDistinct(
            prop,
            abbreviatedString(schemaType(propertySchema).toString(), 30), 
            port));
              
      });
    }
    return props;
  }

  List<String> get definitionEntries {
    List<String> definitions = [];
    if(schema.definitions.length > 0) {
      definitions.add('<tr><td bgcolor="wheat" align="center" colspan="2"><font color="black">Definitions</font></td></tr>');
      schema.definitions.forEach((key, subschema) {
        definitions.add(wrapRowDistinct(key, '', "${schema.path}@$key"));
      });
    }
    return definitions;
  }

  String wrap(String s, {String port : '', String color : 'wheat'}) =>
    s == null? '' :
    '<tr><td bgcolor="$color" align="center" colspan="2" port="$port"><font color="black">$s</font></td></tr>';

  String wrapRowDistinct(String first, String second, [String port='']) =>
    '<tr><td align="left" port="$port">$first</td>$first<td bgcolor="grey" align="right">$second</td></tr>';
  
  String get title =>
    schema.title != null ?
    abbreviatedString("title=${schema.title}", 30) : null;

  String get description =>
    schema.description != null ?
    abbreviatedString("descr=${schema.description}", 30) : null;

  String abbreviatedString(String s, [ int len = 15 ]) {
    if(s == null) return s;
    len -= 3;
    if(len >= s.length) {
      return s;
    } else {
      return s.substring(0, len) + '...';
    }
  }

}


  

// end <schemadot global>


