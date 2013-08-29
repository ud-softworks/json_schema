import "dart:io";
import "package:path/path.dart" as path;

String rootFinder(String desired) {
  var parts = path.split(new Options().script);
  int found = parts.lastIndexOf(desired);
  if(found >= 0) {
    return path.joinAll(parts.getRange(0, found+1));
  }
  throw new 
    StateError("Tests must be initiated from script in 'json_schema'");
}
