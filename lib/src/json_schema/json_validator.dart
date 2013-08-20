part of json_schema;

/// Initialized with schema and will validate json instances against it
class Validator {
  Validator(
    this._schema
  ) {

  }
  
  Schema _schema;
  List<String> _errors;

  // custom <class Validator>

  void _validate(Schema schema, dynamic instance) {
    print("Validating $instance");
  }

  void validate(dynamic instance) {
    _errors = [];
    _validate(_schema, instance);
  }

  // end <class Validator>
}
// custom <part json_validator>
// end <part json_validator>

