// Enforces the M3 theming law: widgets read colours and type from `context`.
//
// Usage: dart run tool/theme_guard.dart [path ...]   (defaults to lib/)
//
// Hex, `ColorScheme` and `TextTheme` may only be defined in lib/core/theme/
// and the lib/main*.dart entrypoints. A colour that is fixed by design is
// allowed when annotated with one of:
//
//   // m3-ignore: <reason>        the same line, or the next line of code
//   // m3-ignore-begin: <reason>  up to the matching // m3-ignore-end
//   // m3-ignore-file: <reason>   the whole file
//
// Exits 0 when clean, 1 on violations, 2 on a bad path argument.

import 'dart:io';

const List<String> _defaultRoots = <String>['lib'];

final List<RegExp> _excludedPaths = <RegExp>[
  RegExp(r'^lib/core/theme/'),
  RegExp(r'^lib/main(_\w+)?\.dart$'),
  RegExp(r'\.(g|freezed)\.dart$'),
];

enum ThemeRule {
  appColors(
    'app-colors',
    'AppColors is the theme input; read a ColorScheme role or context.appColors.',
  ),
  hexColor(
    'hex-color',
    'Hard-coded colour; define it in lib/core/theme/ and read it from context.',
  ),
  materialColors('material-colors', 'Colors.<name> bypasses the theme; use a ColorScheme role.'),
  rawFontSize('raw-font-size', 'Raw fontSize; use a textTheme role or a Constants token.'),
  ignoreMissingReason('ignore-missing-reason', 'm3-ignore needs a reason: // m3-ignore: <why>.'),
  ignoreUnbalanced('ignore-unbalanced', 'm3-ignore-begin and m3-ignore-end are not paired.');

  const ThemeRule(this.id, this.message);

  final String id;
  final String message;
}

class ThemeViolation {
  const ThemeViolation(this.path, this.line, this.column, this.rule, this.snippet);

  final String path;
  final int line;
  final int column;
  final ThemeRule rule;
  final String snippet;

  @override
  String toString() => '$path:$line:$column  ${rule.id}  ${rule.message}\n    $snippet';
}

final List<(ThemeRule, RegExp)> _patterns = <(ThemeRule, RegExp)>[
  (ThemeRule.appColors, RegExp(r'\bAppColors\.\w+')),
  (ThemeRule.hexColor, RegExp(r'\bColor\s*\(\s*0x|\bColor\.from\w*\s*\(')),
  (ThemeRule.materialColors, RegExp(r'\bColors\.(?!transparent\b)\w+')),
  (ThemeRule.rawFontSize, RegExp(r'\bfontSize\s*:\s*[\d.]')),
];

final RegExp _annotation = RegExp(
  r'^//+\s*m3-ignore(-begin|-end|-file)?(?![\w-])\s*(?::\s*(.*))?$',
);
final RegExp _prefixedImport = RegExp(r'''import\s+['"]([^'"]+)['"]\s+as\s+(\w+)\s*;''');

/// Whether [path] (relative, `/`-separated) is allowed to define raw colours.
bool isExcludedPath(String path) => _excludedPaths.any((RegExp r) => r.hasMatch(path));

/// Returns every theme violation in [source], reported against [path].
List<ThemeViolation> scanSource(String path, String source) {
  final _Lexed lexed = _lex(source);
  final String code = lexed.code;
  final List<String> sourceLines = source.split('\n');
  final List<String> codeLines = code.split('\n');
  final List<int> lineStarts = _lineStarts(source);
  final List<ThemeViolation> violations = <ThemeViolation>[];

  ThemeViolation violation(int offset, ThemeRule rule) {
    final int line = _lineOf(lineStarts, offset);
    return ThemeViolation(
      path,
      line + 1,
      offset - lineStarts[line] + 1,
      rule,
      sourceLines[line].trim(),
    );
  }

  final _Ignores ignores = _collectIgnores(
    lexed.comments,
    codeLines,
    lineStarts,
    violation,
    violations,
  );
  if (ignores.wholeFile) return violations;

  final Set<String> foreignPrefixes = <String>{
    for (final RegExpMatch m in _prefixedImport.allMatches(source))
      if (!m.group(1)!.startsWith('package:flutter/') && m.group(1) != 'dart:ui') m.group(2)!,
  };

  for (final (ThemeRule rule, RegExp pattern) in _patterns) {
    for (final RegExpMatch m in pattern.allMatches(code)) {
      if (ignores.covers(_lineOf(lineStarts, m.start))) continue;
      if (_isForeign(code, m.start, rule, foreignPrefixes)) continue;
      violations.add(violation(m.start, rule));
    }
  }

  violations.sort(
    (ThemeViolation a, ThemeViolation b) =>
        a.line != b.line ? a.line.compareTo(b.line) : a.column.compareTo(b.column),
  );
  return violations;
}

// A match on another package's API (e.g. `pw.TextStyle(fontSize: 16)` from
// package:pdf) is not a Flutter theme concern.
bool _isForeign(String code, int offset, ThemeRule rule, Set<String> prefixes) {
  if (prefixes.isEmpty) return false;
  final String? callee = rule == ThemeRule.rawFontSize
      ? _enclosingCallee(code, offset)
      : RegExp(r'(\w+)\.$')
            .firstMatch(code.substring(offset < 64 ? 0 : offset - 64, offset))
            ?.group(0);
  if (callee == null) return false;
  final int dot = callee.indexOf('.');
  return dot > 0 && prefixes.contains(callee.substring(0, dot));
}

String? _enclosingCallee(String code, int offset) {
  int depth = 0;
  for (int i = offset - 1; i >= 0; i--) {
    final String c = code[i];
    if (c == ')' || c == ']' || c == '}') {
      depth++;
    } else if (c == '(' || c == '[' || c == '{') {
      if (depth > 0) {
        depth--;
        continue;
      }
      if (c != '(') return null;
      return RegExp(r'([\w.]+)\s*$').firstMatch(code.substring(i < 200 ? 0 : i - 200, i))?.group(1);
    }
  }
  return null;
}

class _Ignores {
  bool wholeFile = false;
  final Set<int> lines = <int>{};
  final List<(int, int)> ranges = <(int, int)>[];

  bool covers(int line) =>
      lines.contains(line) || ranges.any(((int, int) r) => line >= r.$1 && line <= r.$2);
}

_Ignores _collectIgnores(
  List<(int, String)> comments,
  List<String> codeLines,
  List<int> lineStarts,
  ThemeViolation Function(int, ThemeRule) violation,
  List<ThemeViolation> violations,
) {
  final _Ignores ignores = _Ignores();
  int? openBegin;
  int? openBeginOffset;

  for (final (int offset, String text) in comments) {
    final RegExpMatch? m = _annotation.firstMatch(text.trim());
    if (m == null) continue;
    final String kind = m.group(1) ?? '';
    final bool hasReason = (m.group(2) ?? '').trim().isNotEmpty;
    final int line = _lineOf(lineStarts, offset);

    if (kind != '-end' && !hasReason) {
      violations.add(violation(offset, ThemeRule.ignoreMissingReason));
      continue;
    }
    switch (kind) {
      case '-file':
        ignores.wholeFile = true;
      case '-begin':
        if (openBegin != null)
          violations.add(violation(openBeginOffset!, ThemeRule.ignoreUnbalanced));
        openBegin = line;
        openBeginOffset = offset;
      case '-end':
        if (openBegin == null) {
          violations.add(violation(offset, ThemeRule.ignoreUnbalanced));
        } else {
          ignores.ranges.add((openBegin, line));
          openBegin = null;
        }
      default:
        final int column = offset - lineStarts[line];
        if (codeLines[line].substring(0, column).trim().isNotEmpty) {
          ignores.lines.add(line);
        } else {
          for (int next = line + 1; next < codeLines.length; next++) {
            if (codeLines[next].trim().isNotEmpty) {
              ignores.lines.add(next);
              break;
            }
          }
        }
    }
  }
  if (openBegin != null) violations.add(violation(openBeginOffset!, ThemeRule.ignoreUnbalanced));
  return ignores;
}

class _Lexed {
  _Lexed(this.code, this.comments);

  /// Source with comments and string literals blanked, offsets preserved.
  final String code;
  final List<(int, String)> comments;
}

_Lexed _lex(String src) {
  final List<String> out = src.split('');
  final List<(int, String)> comments = <(int, String)>[];

  void blank(int from, int to) {
    for (int k = from; k < to; k++) {
      if (out[k] != '\n') out[k] = ' ';
    }
  }

  int i = 0;
  while (i < src.length) {
    if (src.startsWith('//', i)) {
      int end = src.indexOf('\n', i);
      if (end < 0) end = src.length;
      comments.add((i, src.substring(i, end)));
      blank(i, end);
      i = end;
    } else if (src.startsWith('/*', i)) {
      final int end = _skipBlockComment(src, i);
      comments.add((i, src.substring(i, end)));
      blank(i, end);
      i = end;
    } else if (src[i] == "'" || src[i] == '"') {
      final int end = _skipString(src, i);
      blank(i, end);
      i = end;
    } else {
      i++;
    }
  }
  return _Lexed(out.join(), comments);
}

int _skipBlockComment(String src, int i) {
  int depth = 0;
  while (i < src.length) {
    if (src.startsWith('/*', i)) {
      depth++;
      i += 2;
    } else if (src.startsWith('*/', i)) {
      depth--;
      i += 2;
      if (depth == 0) return i;
    } else {
      i++;
    }
  }
  return src.length;
}

int _skipString(String src, int start) {
  final String q = src[start];
  final bool raw = start > 0 && src[start - 1] == 'r' && (start < 2 || !_isIdent(src[start - 2]));
  final bool triple = src.startsWith(q * 3, start);
  final String close = triple ? q * 3 : q;
  int i = start + close.length;
  while (i < src.length) {
    if (!triple && src[i] == '\n') return i;
    if (!raw && src[i] == r'\') {
      i += 2;
    } else if (!raw && src.startsWith(r'${', i)) {
      i = _skipInterpolation(src, i + 2);
    } else if (src.startsWith(close, i)) {
      return i + close.length;
    } else {
      i++;
    }
  }
  return src.length;
}

int _skipInterpolation(String src, int i) {
  int depth = 1;
  while (i < src.length) {
    final String c = src[i];
    if (c == "'" || c == '"') {
      i = _skipString(src, i);
      continue;
    }
    if (c == '{') depth++;
    if (c == '}' && --depth == 0) return i + 1;
    i++;
  }
  return src.length;
}

bool _isIdent(String c) => RegExp(r'[\w$]').hasMatch(c);

List<int> _lineStarts(String src) => <int>[
  0,
  for (int i = 0; i < src.length; i++)
    if (src[i] == '\n') i + 1,
];

int _lineOf(List<int> starts, int offset) {
  int lo = 0;
  int hi = starts.length - 1;
  while (lo < hi) {
    final int mid = (lo + hi + 1) >> 1;
    if (starts[mid] <= offset) {
      lo = mid;
    } else {
      hi = mid - 1;
    }
  }
  return lo;
}

String _normalize(String path) {
  final String p = path.replaceAll(r'\', '/');
  return p.startsWith('./') ? p.substring(2) : p;
}

void main(List<String> args) {
  final List<String> roots = args.isEmpty ? _defaultRoots : args;
  final List<String> files = <String>[];

  for (final String root in roots) {
    final FileSystemEntityType type = FileSystemEntity.typeSync(root);
    if (type == FileSystemEntityType.file) {
      files.add(_normalize(root));
    } else if (type == FileSystemEntityType.directory) {
      files.addAll(
        Directory(root)
            .listSync(recursive: true)
            .whereType<File>()
            .map((File f) => _normalize(f.path))
            .where((String p) => p.endsWith('.dart')),
      );
    } else {
      stderr.writeln('theme_guard: no such file or directory: $root');
      exitCode = 2;
      return;
    }
  }

  final List<String> scanned = files.where((String p) => !isExcludedPath(p)).toList()..sort();
  final List<ThemeViolation> violations = <ThemeViolation>[
    for (final String path in scanned) ...scanSource(path, File(path).readAsStringSync()),
  ];

  for (final ThemeViolation v in violations) {
    stdout.writeln(v);
  }
  if (violations.isEmpty) {
    stdout.writeln('theme_guard: ${scanned.length} files clean.');
  } else {
    stdout.writeln(
      'theme_guard: ${violations.length} violation(s) in ${scanned.length} files. '
      'Read the colour/type from context, or annotate a fixed-by-design value with // m3-ignore: <reason>.',
    );
    exitCode = 1;
  }
}
