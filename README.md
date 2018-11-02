# JSON Schema

  A *platform agnostic* (dart:html or dart:io) Dart library for validating JSON instances against JSON Schemas (multi-version support with latest of Draft 6).

![Build Status](https://travis-ci.org/workiva/json_schema.svg)

## How To Create a Schema
  
### Synchronous Creation, no $refs (Default Behavior):
  
The simplest way to create a schema is to pass JSON data directly to `JsonSchema.createSchema` with a JSON `String`, or decoded JSON via Dart `Map` or `bool`.
    
    Note: Creating JsonSchemas synchronously implies access to all $refs within the root schema. If you don't have access to all this data at the time of the construction, see "Asynchronous Creation".


#### Example (Synchronous, Self-Contained Schema)

A schema can be created with a Map that is either hand-crafted, referneced from a JSON file, or *previously* fetched from the network or file system.

  ```dart
/// Define schema in a Dart [Map] or use a JSON [String].
var mustBeIntegerSchemaMap = {
"type" : "integer"
};

// Create some examples to validate against the schema.
var n = 3;
var decimals = 3.14;
var str = 'hi';

// Construct the schema from the schema map or JSON string.
final schema = JsonSchema.createSchema(mustBeIntegerSchema);

print('$n => ${schema.validate(n)}'); // true
print('$decimals => ${schema.validate(decimals)}'); // false
print('$str => ${schema.validate(str)}'); // false
  ```

### Synchronous Creation, with locally cached $refs:

If you want to create `JsonSchema`s synchronously, and you have $refs that cannot be resolved within the root schema, but you have a cache of those $ref'd schemas locally, you can write a `RefProvider` to get them during schema evaluation.

### Asynchronous Creation, with remote HTTP $refs:

If you have schemas that have nested $refs that are HTTP URIs that are publically accessible, you can use `Future<JsonSchema> JsonSchema.createSchemaAsync` and the references will be fetched as needed during evaluation. You can also use `JsonSchema.createSchemaFromUrl` if you want to fetch the root schema remotely as well.

#### Example 1 (createSchemaAsync)

```dart
// TODO
```

#### Example 2 (createSchemaFromUrl)

```dart
String url = "http://json-schema.org/draft-04/schema";
final schema = await JsonSchema.createSchemaFromUrl(url)
print('Does schema validate itself? ${schema.validate(schema.schemaMap)}');
```

    In this example a schema is created from the url and its stored
    contents are validated against itself. Since the referenced schema
    is the schema for schemas and the instance is, of course, a schema,
    the result prints true.

### Asynchronous Creation, with custom remote $refs:

If you have nested $refs that are either non-HTTP URIs or non-publically-accessible HTTP $refs, you can supply an `AsyncRefProvider` to `createSchemaAsync`, and 


#### Example

```dart
// TODO
```


## How To Validate JSON againt a schema

To validate instances against a `JsonSchema` first create the schema, then call validate on it with an json instance (Dart `Map` or JSON `String`). This can be done with an url:

### Example 2
  
  An url can point to a local file, either of format
  _file:///absolute\_path\_to/schema.json_ or _subfolder/schema.json_
  where _subfolder_ is a subfolder of current working directory. An
  example of this can be found in
  _example/from\_url/validate\_instance\_from\_url.dart_

      url = "grades_schema.json";
      JsonSchema.createSchemaFromUrl(url)
        .then((schema) {
          var grades = JSON.parse('''
    {
        "semesters": [
            {
                "semester": 1,
                "grades": [
                    {
                        "type": "homework",
                        "date": "09/27/2013",
                        "grade": 100,
                        "avg": 93,
                        "std": 8
                    },
                    {
                        "type": "homework",
                        "date": "09/28/2013",
                        "grade": 100,
                        "avg": 60,
                        "std": 25
                    }
                ]  
            }
          ]
    }''');
          
          print('''Does grades schema validate $grades
      ${schema.validate(grades)}''');

  In this example the schema is read from file _grades\_schema.json_
  in the current directory and a valid instance is submitted for
  validation (in the string of the print statement). This example also
  prints true.

# How To Use Schema Information

  Schema information can be used for validation; but it can also be a
  valuable source of information about the structure of data. The
  Schema class provided here works by fully parsing the schema first,
  which itself must be valid on all paths within the schema. The only
  invalid content of a provided schema are _free-form properties_
  containing schema that are not referenced. Accessors are provided
  for the meta-data associated with a schema, so tools can do *stuff*
  with it. 

  One example use is the _schemadot_ program included in the _bin_
  folder which takes schema as input and outputs a _Graphviz_ _dot_
  file, providing a picture of the schema. This does not provide all
  information of the schema, and is a work in progress - but it can be
  useful to *see* what a schema is.

  For example, the grades_schema.json is:

    {
        "$schema": "http://json-schema.org/draft-04/schema#",
        "title" : "Grade Tracker",
        "type" : "object",
        "additionalProperties" : false,
        "properties" : {
    	"semesters" : {
    	    "type" : "array",
    	    "items" : {
                    "type" : "object",
                    "additionalProperties" : false,
                    "properties" : {
                        "semester": { "type" : "integer" },
                        "grades" : {
                            "type" : "array",
                            "items" : {
                                "type" : "object",
                                "additionalProperties" : false,
                                "required" : [ "date", "type", "grade", "std" ],
                                "properties" : {
                                    "date" : { "type" : "string"},
                                    "type" : { "enum" : [ "homework", "quiz", "test", "final_exam" ] },
                                    "grade" : { "type" : "number"},
                                    "std" : { 
                                        "oneOf" : [ 
                                            {"type" : "number"}, 
                                            {"type" : "null"}
                                        ] 
                                    },
                                    "avg" : { 
                                        "oneOf" : [ 
                                            {"type" : "number"}, 
                                            {"type" : "null"}
                                        ] 
                                    }
                                }
                            }
                        }
                    }
                }
      	    }
        }
    }

  And the generated image is:

  ![Grades!](https://raw.github.com/patefacio/json_schema/master/example/from_url/grades_schema.png)  

  For more detailed image open link:
  <a href="https://raw.github.com/patefacio/json_schema/master/example/from_url/grades_schema.png"
  target="_blank">Grade example schema diagram</a>
