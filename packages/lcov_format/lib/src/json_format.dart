import 'dart:io';

import 'package:lcov_format/lcov.dart';
import 'package:path/path.dart' as path;
import 'package:syntax_highlight_lite/syntax_highlight_lite.dart';

Future<void> jsonFormat(
  LcovNode node,
  Future<Null> Function(LcovRecord record,
          ({Map<String, dynamic> highlight, Map<String, dynamic> lcov, String fullPath}))
      handleRecord,
) async {
  await Highlighter.initialize(['dart']);
  var theme = await HighlighterTheme.loadDarkTheme();
  var highlighter = Highlighter(
    language: 'dart',
    theme: theme,
  );

  printFile(String fullPath, TextSpan fileSpan, LcovRecord node) {
    handleRecord(node, (
      highlight: fileSpan.toJson(),
      lcov: node.toJson(),
      fullPath: fullPath,
    ));
  }

  for (var child in node.children.values) {
    final parent = path.split(child.path).takeWhile((d) => d != 'coverage');
    LcovVisitor((child, depth) {
      if (child is LcovRecord) {
        final fullPath = path.joinAll([...parent, ...path.split(child.path)]);
        final spans = highlighter.highlight(File(fullPath).readAsStringSync());
        printFile(fullPath, spans, child);
      }
    }).visit(child);
  }
}
