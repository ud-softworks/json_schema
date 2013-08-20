part of json_schema;

/// Initialized with schema, validates instances against it
class Validator {
  Validator(
    this._schema
  ) {

  }
  
  Schema _schema;

  // custom <class Validator>

  bool validate(dynamic instance) {
    var validation = new _Validation(_schema, instance);
    return validation.errors.length == 0;
  }

  // end <class Validator>
}

class _Validation {
  _Validation(
    this.schema,
    this.instance
  ) {
    // custom <_Validation>

    _typeValidation();
    if(instance is List) _itemsValidation();
    if(instance is String) _stringValidation();
    if(instance is num || instance is int) _numberValidation();

    // end <_Validation>
  }
  
  Schema schema;
  dynamic instance;
  List<String> errors = [];

  // custom <class Validation>

  static bool _typeMatch(SchemaType type, dynamic instance) {
    switch(type) {
      case SchemaType.OBJECT: return instance is Map;
      case SchemaType.STRING: return instance is String;
      case SchemaType.INTEGER: return instance is int;
      case SchemaType.NUMBER: return instance is num;
      case SchemaType.ARRAY: return instance is List;
      case SchemaType.BOOLEAN: return instance is bool;
      case SchemaType.NULL: return instance == null;
    }
    return false;
  }

  void _numberValidation() {
  }

  void _typeValidation() {
    var typeList = schema._schemaTypeList;
    if(typeList != null) {
      if(!typeList.any((type) => _typeMatch(type, instance))) {
        errors.add("${schema._path}: type: wanted ${typeList}");
      }
    }
  }

  void _stringValidation() {
    int actual = instance.length;
    var minLength = schema._minLength;
    var maxLength = schema._maxLength;
    if(maxLength is int && actual > maxLength) {
      errors.add("${schema._path}: maxLength exceeded ($actual vs $maxLength)");
    } else if(minLength is int && actual < minLength) {
      errors.add("${schema._path}: minLength violated ($actual vs $minLength)");
    }
  }

  void _itemsValidation() {
    int actual = instance.length;

    var singleSchema = schema._items;
    var additionalItems = schema._additionalItems;
    if(singleSchema != null) {
      instance.forEach((item) {
        var v = new _Validation(singleSchema, item);
        errors.addAll(v.errors);
      });
    } else {
      var items = schema._itemsList;
      var additionalItems = schema._additionalItems;
  
      if(items != null) {
        int expected = items.length;
        int end = min(expected, actual);
        for(int i=0; i<end; i++) {
          var v = new _Validation(items[i], instance[i]);
          errors.addAll(v.errors);
        }
        if(additionalItems is Schema) {
          for(int i=end; i<actual; i++) {
            var v = new _Validation(additionalItems, instance[i]);
            errors.addAll(v.errors);
          }
        } else if(additionalItems is bool) {
          if(!additionalItems && actual > end) {
            errors.add("${schema._path}: additionalItems false");
          }
        }
      }
    }

    var maxItems = schema._maxItems;
    var minItems = schema._minItems;
    if(maxItems is int && actual > maxItems) {
      errors.add("${schema._path}: maxItems exceeded ($actual vs $maxItems)");
    } else if(schema._minItems is int && actual < schema._minItems) {
      errors.add("${schema._path}: minItems violated ($actual vs $minItems)");
    }
    
  }

  // end <class Validation>
}
// custom <part json_validator>
// end <part json_validator>

