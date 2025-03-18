import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:lcov_format/lcov.dart';
import 'package:path/path.dart' as path;
import 'package:syntax_highlight_lite/syntax_highlight_lite.dart';

ansiFormat(
  LcovNode node,
) async {
  await Highlighter.initialize(['dart']);
  var theme = await HighlighterTheme.loadDarkTheme();
  var highlighter = Highlighter(
    language: 'dart',
    theme: theme,
  );

  final ansiScopes = <int, AnsiPen>{};
  for (final MapEntry(:value) in theme.scopes.entries) {
    // Finds nearest xterm color.
    ansiScopes[value.foreground.argb] = AnsiPen()
      ..rgb(
          r: ((value.foreground.argb & 0xFF0000) >> 16) / 255,
          g: ((value.foreground.argb & 0xFF00) >> 8) / 255,
          b: (value.foreground.argb & 0xFF) / 255);
  }

  printFile(TextSpan fileSpan, LcovRecord node, String fullPath) {
    final zero = AnsiPen()
      ..red(bg: true)
      ..black();
    final cover = AnsiPen()
      ..green(bg: true)
      ..black();
    stdout.writeln('');
    stdout.writeln(
        '────┤ $fullPath [${node.linesHit} / ${node.linesFound}] = ${node.percent.toStringAsFixed(2)}% ├────');

    int lineNumber = 1;
    writeLineHeader() {
      var hits = node.lines[lineNumber];
      if (hits == null) {
        stdout.write('$ansiDefault${' ' * 8} | ');
      } else if (hits == 0) {
        stdout.write('$ansiDefault${zero('$hits'.padLeft(8, ' '))} | ');
      } else {
        stdout.write('$ansiDefault${cover('$hits'.padLeft(8, ' '))} | ');
      }
    }

    writeLineHeader();
    SpanVisitor(
      (span, depth) {
        if (span.text == null) {
          return;
        }
        var text = span.text!;

        final argb = span.style?.foreground.argb ?? 0xFFFFFFFF;
        final pen = ansiScopes[argb] ??= AnsiPen()
          ..rgb(
              r: ((argb & 0xFF0000) >> 16) / 255,
              g: ((argb & 0xFF00) >> 8) / 255,
              b: (argb & 0xFF) / 255);

        stdout.write(pen.down);
        for (int i = 0; i < text.length; i++) {
          final char = text[i];
          stdout.write(char);
          if (char == '\n') {
            lineNumber++;
            writeLineHeader();
            stdout.write(pen.down);
          }
        }
      },
    ).visit(fileSpan);
  }

  for (var child in node.children.values) {
    final parent = path.split(child.path).takeWhile((d) => d != 'coverage');
    LcovVisitor((node, depth) {
      if (node is LcovRecord) {
        final fullPath = path.joinAll([...parent, ...path.split(node.path)]);
        final spans = highlighter.highlight(File(fullPath).readAsStringSync());
        printFile(spans, node, fullPath);
      }
    }).visit(child);
  }
}
