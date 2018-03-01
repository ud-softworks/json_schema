// Copyright 2013-2018 Workiva Inc.
//
// Licensed under the Boost Software License (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.boost.org/LICENSE_1_0.txt
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This software or document includes material copied from or derived
// from JSON-Schema-Test-Suite (https://github.com/json-schema-org/JSON-Schema-Test-Suite),
// Copyright (c) 2012 Julian Berman, which is licensed under the following terms:
//
//     Copyright (c) 2012 Julian Berman
//
//     Permission is hereby granted, free of charge, to any person obtaining a copy
//     of this software and associated documentation files (the "Software"), to deal
//     in the Software without restriction, including without limitation the rights
//     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//     copies of the Software, and to permit persons to whom the Software is
//     furnished to do so, subject to the following conditions:
//
//     The above copyright notice and this permission notice shall be included in
//     all copies or substantial portions of the Software.
//
//     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//     THE SOFTWARE.

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
