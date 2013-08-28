#!/usr/bin/env dart
/// 
/// Usage: schemadot --in-uri INPUT_JSON_URI --out-file OUTPUT_FILE
/// 
/// Given an input uri [in-uri] processes content of uri as
/// json schema and generates input file for Graphviz dot
/// program. If [out-file] provided, output is written to 
/// to the file, otherwise written to stdout.
/// 

import "package:json_schema/json_schema.dart";
import "dart:json" as JSON;
import "dart:async";
import "dart:io";
import "package:args/args.dart";
import "package:logging/logging.dart";
import "package:logging_handlers/logging_handlers_shared.dart";

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
  print(uri);

  completer.future.then((schemaText) {
    Future schema = Schema.createSchema(JSON.parse(schemaText));
    schema.then((schema) {
      List<String> definitions = [];
      List<String> properties = [];
      
      schema.properties.forEach((prop, propertySchema) {
        properties.add('''
  <tr><td align="left" port="$prop">$prop</td><td bgcolor="grey" align="right"></td></tr>
''');
      });

      String propertyText = properties.length == 0? '' :
        '''
  <tr><td bgcolor="wheat" align="center" colspan="2"><font color="black">Properties</font></td></tr>
  <hr/>
  ${properties.join('\n  ')}
''';
      
      schema.definitions.forEach((definitionKey, definition) {
        definitions.add('''
  <tr><td bgcolor="AntiqueWhite" align="center" port="_title"><font color="black">$definitionKey</font></td></tr>
''');
      });

      String definitionText = definitions.length == 0? '' :
        '''
  <tr><td bgcolor="peachpuff" align="center" colspan="2"><font color="black">Definitions</font></td></tr>
  <hr/>
  ${definitions.join('\n  ')}
''';
      
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

subgraph {
  "${schema.path}" [
    label =<
<table border="0" cellborder="0" cellpadding="1" bgcolor="white">
  <tr><td bgcolor="AntiqueWhite" align="center" colspan="2" port="#title"><font color="black">${schema.path}</font></td></tr>

${definitionText}
${propertyText}
</table>
>
  ];
}


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
// end <schemadot global>


