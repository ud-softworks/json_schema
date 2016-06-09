import 'dart:io';
import 'package:logging/logging.dart';
import 'package:coverage/coverage.dart';
import 'package:ebisu/ebisu.dart';
import 'runner.dart' as runner;
import 'package:path/path.dart';


main() async {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  final here = Platform.script.toFilePath();
  final results = await runAndCollect('runner.dart');

  final untested = {};
  results['coverage'].forEach((var entry) {
    final source = entry['source'];
    if(!source.contains('package:json_schema')) return;
    print(source);
    final hits = entry['hits'];
    final hitCount = hits.length/2;
    for(int i=0; i<hitCount; i+=2) {
      final lineNumber = hits[i];
      final count = hits[i+1];
      if(count == 0) {
        untested.putIfAbsent(entry['source'], () => []).add(lineNumber);
      }
    }
  });

  print(untested);
}
