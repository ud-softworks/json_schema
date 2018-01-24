class SchemaType implements Comparable<SchemaType> {
  static const SchemaType ARRAY = const SchemaType._(0);

  static const SchemaType BOOLEAN = const SchemaType._(1);

  static const SchemaType INTEGER = const SchemaType._(2);

  static const SchemaType NUMBER = const SchemaType._(3);

  static const SchemaType NULL = const SchemaType._(4);

  static const SchemaType OBJECT = const SchemaType._(5);

  static const SchemaType STRING = const SchemaType._(6);

  static List<SchemaType> get values => const <SchemaType>[ARRAY, BOOLEAN, INTEGER, NUMBER, NULL, OBJECT, STRING];

  final int value;

  int get hashCode => value;

  const SchemaType._(this.value);

  SchemaType copy() => this;

  int compareTo(SchemaType other) => value.compareTo(other.value);

  String toString() {
    switch (this) {
      case ARRAY:
        return 'array';
      case BOOLEAN:
        return 'boolean';
      case INTEGER:
        return 'integer';
      case NUMBER:
        return 'number';
      case NULL:
        return 'null';
      case OBJECT:
        return 'object';
      case STRING:
        return 'string';
    }
    return null;
  }

  static SchemaType fromString(String s) {
    if (s == null) return null;
    switch (s) {
      case 'array':
        return ARRAY;
      case 'boolean':
        return BOOLEAN;
      case 'integer':
        return INTEGER;
      case 'number':
        return NUMBER;
      case 'null':
        return NULL;
      case 'object':
        return OBJECT;
      case 'string':
        return STRING;
      default:
        return null;
    }
  }
}