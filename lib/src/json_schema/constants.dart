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

class JsonSchemaValidationRegexes {
  static RegExp email = new RegExp(r'^[_A-Za-z0-9-\+]+(\.[_A-Za-z0-9-]+)*'
      r'@'
      r'[A-Za-z0-9-]+(\.[A-Za-z0-9]+)*(\.[A-Za-z]{2,})$');

  static RegExp ipv4 = new RegExp(r'^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.'
      r'(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.'
      r'(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.'
      r'(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$');

  static RegExp ipv6 = new RegExp(r'(^([0-9a-f]{1,4}:){1,1}(:[0-9a-f]{1,4}){1,6}$)|'
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
      r'(^:(:[0-9a-f]{1,4}){1,5}:(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}$)');

  static RegExp hostname = new RegExp(r'^(?=.{1,255}$)'
      r'[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?'
      r'(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?)*\.?$');

  static RegExp jsonPointer = new RegExp(r'^(?:\/(?:[^~/]|~0|~1)*)*$');
}

class JsonSchemaVersions {
  static const String draft4 = 'http://json-schema.org/draft-04/schema#';
  static const String draft6 = 'http://json-schema.org/draft-06/schema#';

  static List<String> allVersions = const [
    draft4,
    draft6,
  ];
}
