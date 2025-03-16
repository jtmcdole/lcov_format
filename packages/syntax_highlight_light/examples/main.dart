import 'dart:convert';

import 'package:syntax_highlight_light/syntax_highlight_light.dart';

main() async {
  await Highlighter.initialize(['dart']);
  var theme = await HighlighterTheme.loadDarkTheme();
  var highlighter = Highlighter(
    language: 'dart',
    theme: theme,
  );

  final span = highlighter.highlight('''
void main(List<String> args) async {
  await foo();
  print('sup dawg');



}
''');

  SpanVisitor(
    (node, depth) {
      var text = node.text ?? '';
      if (LineSplitter.split(text).length > 1) {
        text = 'NEWLINEs(${LineSplitter.split(text).length})';
      }
      print('  ' * depth +
          '$text - ${(
            node.style?.bold,
            node.style?.italic,
            node.style?.underline,
            node.style?.foreground.argb
          )}');
    },
  ).visit(span);
}
