import 'package:flutter_test/flutter_test.dart';

// Copy to test/theme_guard_test.dart; it imports the guard from tool/.

import '../tool/theme_guard.dart';

List<String> _rules(String source) =>
    scanSource('lib/x.dart', source).map((ThemeViolation v) => '${v.line}:${v.rule.id}').toList();

void main() {
  test('flags raw colours and font sizes', () {
    expect(
      _rules('''
final a = AppColors.primary;
final b = const Color(0xFF005E89);
final c = Color.fromARGB(255, 0, 0, 0);
final d = Colors.white;
final e = TextStyle(fontSize: 18);
'''),
      <String>[
        '1:app-colors',
        '2:hex-color',
        '3:hex-color',
        '4:material-colors',
        '5:raw-font-size',
      ],
    );
  });

  test('allows theme reads, transparent and token font sizes', () {
    expect(
      _rules('''
final a = Theme.of(context).colorScheme.primary;
final b = Colors.transparent;
final c = TextStyle(fontSize: Constants.iconMd);
final d = PdfColors.grey;
'''),
      isEmpty,
    );
  });

  test('ignores comments and string literals', () {
    expect(
      _rules(r'''
// AppColors.primary and Color(0xFF000000)
/* Colors.white /* nested */ fontSize: 12 */
final s = 'Colors.red ${x ? 'AppColors.primary' : "y"}';
final t = """
Color(0xFF123456)
""";
'''),
      isEmpty,
    );
  });

  test('m3-ignore covers the next code line after a comment block, or its own line', () {
    expect(
      _rules('''
// m3-ignore: fixed brand gradient, identical in light and dark — the
// same lockup gradient used by the dashboard header.
final a = AppColors.primaryGradient;
final b = Colors.white; // m3-ignore: camera overlay
final c = Colors.white;
'''),
      <String>['5:material-colors'],
    );
  });

  test('m3-ignore-begin/-end covers a range, and -file covers everything', () {
    expect(
      _rules('''
// m3-ignore-begin: camera scrim
final a = Colors.black;
final b = Color(0x99000000);
// m3-ignore-end
final c = Colors.black;
'''),
      <String>['5:material-colors'],
    );
    expect(_rules('// m3-ignore-file: brand splash\nfinal a = Colors.black;\n'), isEmpty);
  });

  test('annotations without a reason or pairing are violations', () {
    expect(
      _rules('''
// m3-ignore
final a = Colors.black;
// m3-ignore-end
// m3-ignore-begin: never closed
'''),
      <String>[
        '1:ignore-missing-reason',
        '2:material-colors',
        '3:ignore-unbalanced',
        '4:ignore-unbalanced',
      ],
    );
  });

  test('skips APIs from non-Flutter import prefixes', () {
    expect(
      _rules('''
import 'package:pdf/widgets.dart' as pw;
final a = pw.TextStyle(
  fontWeight: pw.FontWeight.bold,
  fontSize: 16,
);
final b = TextStyle(fontSize: 16);
'''),
      <String>['6:raw-font-size'],
    );
  });

  test('theme layer, entrypoints and generated files are excluded', () {
    expect(isExcludedPath('lib/core/theme/app_colors.dart'), isTrue);
    expect(isExcludedPath('lib/main.dart'), isTrue);
    expect(isExcludedPath('lib/main_dev.dart'), isTrue);
    expect(isExcludedPath('lib/app/x.g.dart'), isTrue);
    expect(
      isExcludedPath('lib/modules/features/dashboard/presentation/dashboard_view.dart'),
      isFalse,
    );
  });
}
