library hop_runner;

import 'dart:async';
import 'dart:io';
import 'package:hop/hop.dart';
import "package:path/path.dart" as PATH;
import 'package:hop/hop_tasks.dart';
import '../test/root_finder.dart';
import '../test/test_runner.dart' as TEST_RUNNER;

void main() {

  Directory.current = rootFinder('json_schema');

  addTask('analyze_lib', createAnalyzerTask(_getLibs));
  addTask('analyze_test', 
      createAnalyzerTask([
        'test/test_invalid_schemas.dart',
        'test/test_validation.dart',
      ]));

  addTask('docs', createDartDocTask(_getLibs));

  addTask('test', createUnitTestTask(TEST_RUNNER.testCore));

  runHop();
}

Future<List<String>> _getLibs() {
  return new Directory('lib').list()
      .where((FileSystemEntity fse) => fse is File)
      .map((File file) => file.path)
      .toList();
}
