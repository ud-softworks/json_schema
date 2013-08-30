/// Support for validating json instances against a json schema
library json_schema;

import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'dart:json' as JSON;
import 'package:path/path.dart' as PATH;
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
part "src/json_schema/schema.dart";
part "src/json_schema/validator.dart";

final _logger = new Logger("json_schema");

class SchemaType {
  static const ARRAY = const SchemaType._(0);
  static const BOOLEAN = const SchemaType._(1);
  static const INTEGER = const SchemaType._(2);
  static const NUMBER = const SchemaType._(3);
  static const NULL = const SchemaType._(4);
  static const OBJECT = const SchemaType._(5);
  static const STRING = const SchemaType._(6);

  static get values => [
    ARRAY,
    BOOLEAN,
    INTEGER,
    NUMBER,
    NULL,
    OBJECT,
    STRING
  ];

  final int value;

  const SchemaType._(this.value);

  String toString() {
    switch(this) {
      case ARRAY: return "array";
      case BOOLEAN: return "boolean";
      case INTEGER: return "integer";
      case NUMBER: return "number";
      case NULL: return "null";
      case OBJECT: return "object";
      case STRING: return "string";
    }
  }

  static SchemaType fromString(String s) {
    switch(s) {
      case "array": return ARRAY;
      case "boolean": return BOOLEAN;
      case "integer": return INTEGER;
      case "number": return NUMBER;
      case "null": return NULL;
      case "object": return OBJECT;
      case "string": return STRING;
    }
  }


  // custom <enum SchemaType>
  // end <enum SchemaType>

}

// custom <library json_schema>

bool logFormatExceptions = false;

bool _jsonEqual(a, b) {
  bool result = true;
  if(a is Map && b is Map) {
    if(a.length != b.length) return false;
    a.keys.forEach((k) {
      if(!_jsonEqual(a[k], b[k])) {
        result = false;
        return;
      }
    });
  } else if(a is List && b is List) {
    if(a.length != b.length) return false;
    for(int i=0; i<a.length; i++) {
      if(!_jsonEqual(a[i], b[i])) {
        return false;
      }
    }
  } else {
    return a == b;
  }
  return result;
}

// end <library json_schema>

