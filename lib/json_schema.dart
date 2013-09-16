/// Support for validating json instances against a json schema
library json_schema;

import 'dart:io';
import 'dart:math';
import 'dart:convert' as convert;
import 'package:path/path.dart' as PATH;
import 'dart:async';
import 'package:logging/logging.dart';
// custom <additional imports>
// end <additional imports>

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

RegExp _emailRe = new RegExp(
  r'^[_A-Za-z0-9-\+]+(\.[_A-Za-z0-9-]+)*'
  r'@'
  r'[A-Za-z0-9-]+(\.[A-Za-z0-9]+)*(\.[A-Za-z]{2,})$'
);

var _defaultEmailValidator = (String email) => _emailRe.firstMatch(email) != null;

var _emailValidator = _defaultEmailValidator;

RegExp _ipv4Re = new RegExp(
  r'^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.'
  r'(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.'
  r'(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.'
  r'(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$'
);

RegExp _ipv6Re = new RegExp(
  r'(^([0-9a-f]{1,4}:){1,1}(:[0-9a-f]{1,4}){1,6}$)|'
  r'(^([0-9a-f]{1,4}:){1,2}(:[0-9a-f]{1,4}){1,5}$)|'
  r'(^([0-9a-f]{1,4}:){1,3}(:[0-9a-f]{1,4}){1,4}$)|'
  r'(^([0-9a-f]{1,4}:){1,4}(:[0-9a-f]{1,4}){1,3}$)|'
  r'(^([0-9a-f]{1,4}:){1,5}(:[0-9a-f]{1,4}){1,2}$)|'
  r'(^([0-9a-f]{1,4}:){1,6}(:[0-9a-f]{1,4}){1,1}$)|'
  r'(^(([0-9a-f]{1,4}:){1,7}|:):$)|'
  r'(^:(:[0-9a-f]{1,4}){1,7}$)|'
  r'(^((([0-9a-f]{1,4}:){6})(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})$)|'
  r'(^(([0-9a-f]{1,4}:){5}[0-9a-f]{1,4}:(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})$)|'
  r'(^([0-9a-f]{1,4}:){5}:[0-9a-f]{1,4}:(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$)|'
  r'(^([0-9a-f]{1,4}:){1,1}(:[0-9a-f]{1,4}){1,4}:(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$)|'
  r'(^([0-9a-f]{1,4}:){1,2}(:[0-9a-f]{1,4}){1,3}:(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$)|'
  r'(^([0-9a-f]{1,4}:){1,3}(:[0-9a-f]{1,4}){1,2}:(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$)|'
  r'(^([0-9a-f]{1,4}:){1,4}(:[0-9a-f]{1,4}){1,1}:(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$)|'
  r'(^(([0-9a-f]{1,4}:){1,5}|:):(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$)|'
  r'(^:(:[0-9a-f]{1,4}){1,5}:(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$)'
);

var _defaultUriValidator = (String uri) {
  try {
    Uri.parse(uri);
    return true;
  } catch(e) {
    return false;
  }
};

RegExp _hostnameRe = new RegExp(
  r'^(?=.{1,255}$)'
  r'[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?'
  r'(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?)*\.?$'
);

var _uriValidator = _defaultUriValidator;

// custom <library json_schema>

/// Used to provide your own uri validator (if default does not suit needs)
set uriValidator(bool validator(String)) => _uriValidator = validator;

/// Used to provide your own email validator (if default does not suit needs)
set emailValidator(bool validator(String)) => _emailValidator = validator;

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

