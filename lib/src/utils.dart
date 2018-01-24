// UTILTY FUNCTIONS

bool _jsonEqual(a, b) {
  bool result = true;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    a.keys.forEach((k) {
      if (!_jsonEqual(a[k], b[k])) {
        result = false;
        return;
      }
    });
  } else if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_jsonEqual(a[i], b[i])) {
        return false;
      }
    }
  } else {
    return a == b;
  }
  return result;
}

