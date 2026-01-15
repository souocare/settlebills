// This is a simple logging utility for HTTP requests and responses, to use during development.

import 'package:flutter/foundation.dart';

const bool kHttpLogEnabled = true;

/// Pretty-print helper (safe for huge payloads).
String pretty(Object? value, {int maxLen = 12000}) {
  final s = value?.toString() ?? '';
  if (s.length <= maxLen) return s;
  return '${s.substring(0, maxLen)}\n...<truncated>';
}

void logLine(String message) {
  if (!kHttpLogEnabled) return;
  debugPrint(message);
}