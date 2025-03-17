import 'dart:convert';

import 'package:characters/characters.dart';

import 'grammars/dart.dart';

import 'themes/dark_vs.dart';
import 'themes/dark_plus.dart';
import 'themes/light_plus.dart';
import 'themes/light_vs.dart';

import 'span_parser.dart';

class Color {
  final int argb;

  const Color(this.argb);
}

final _bracketStyles = <TextStyle>[
  TextStyle(foreground: Color(0xFF5caeef)),
  TextStyle(foreground: Color(0xFFdfb976)),
  TextStyle(foreground: Color(0xFFc172d9)),
  TextStyle(foreground: Color(0xFF4fb1bc)),
  TextStyle(foreground: Color(0xFF97c26c)),
  TextStyle(foreground: Color(0xFFabb2c0)),
];

final _failedBracketStyle = TextStyle(foreground: Color(0xFFff0000));

const _defaultLightThemeFiles = [
  kLightVs,
  kLightPlus,
];

const _defaultDarkThemeFiles = [
  kDarkVs,
  kDarkPlus,
];

class TextStyle {
  final Color foreground;
  final bool underline;
  final bool bold;
  final bool italic;

  TextStyle({
    this.foreground = const Color(0xFF000000),
    this.underline = false,
    this.bold = false,
    this.italic = false,
  });

  TextStyle.fromJson(Map<String, dynamic> json)
      : foreground = Color(json['fg']),
        underline = json['u'] ?? false,
        bold = json['ub'] ?? false,
        italic = json['i'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'fg': foreground.argb,
      if (underline) 'u': underline,
      if (bold) 'b': bold,
      if (italic) 'i': italic,
    };
  }
}

class TextSpan {
  String? text;
  TextStyle? style;
  List<TextSpan> children;
  List<String> scopes;

  TextSpan({this.text, this.style, List<TextSpan>? children, List<String>? scopes})
      : children = children ?? <TextSpan>[],
        scopes = scopes ?? <String>[];

  TextSpan.fromJson(Map<String, dynamic> json)
      : text = json['t'],
        style = json['st'] != null ? TextStyle.fromJson(json['st']) : null,
        scopes = [for (var scope in json['sc'] ?? []) '$scope'],
        children = [for (final child in json['c'] ?? []) TextSpan.fromJson(child)];

  Map<String, dynamic> toJson() {
    return {
      if (text != null) 't': text,
      if (style != null) 'st': style,
      if (scopes.isNotEmpty) 'sc': scopes,
      if (children.isNotEmpty) 'c': [for (final child in children) child.toJson()]
    };
  }
}

/// The [Highlighter] class can format a String of code and add syntax
/// highlighting in the form of a [TextSpan]. Currrently supports Dart and
/// YAML. Formatting style is similar to VS Code.
class Highlighter {
  static final _cache = <String, Grammar>{};

  /// Creates a [Highlighter] for the given [language] and [theme]. The
  /// [language] must be one of the languages supported by this package,
  /// unless it has been manually added. Before creating a [Highlighter],
  /// you must call [initialize] with a list of languages to load.
  Highlighter({
    required this.language,
    required this.theme,
  }) {
    _grammar = _cache[language]!;
  }

  /// Initializes the [Highlighter] with the given list of [languages]. This
  /// must be called before creating any [Highlighter]s. Supported languages
  /// are 'dart' and 'yaml'.
  static Future<void> initialize(List<String> languages) async {
    // for (var language in languages) {
    _cache['dart'] = Grammar.fromJson(jsonDecode(kDartGrammar));
    // }
  }

  /// Adds a custom language to the list of languages.
  /// Associates a language [name] with a TextMate formatted [json] definition.
  /// This must be called before creating any [Highlighter]s.
  static void addLanguage(String name, String json) {
    _cache.putIfAbsent(name, () => Grammar.fromJson(jsonDecode(json)));
  }

  /// The language of this [Highlighter].
  final String language;

  late final Grammar _grammar;

  /// The [HighlighterTheme] used to style the code.
  final HighlighterTheme theme;

  /// Formats the given [code] and returns a [TextSpan] with syntax
  /// highlighting.
  TextSpan highlight(String code) {
    var spans = SpanParser.parse(_grammar, code);
    var textSpans = <TextSpan>[];
    var bracketCounter = 0;

    int charPos = 0;
    for (var span in spans) {
      // Add any text before the span.
      if (span.start > charPos) {
        var text = code.substring(charPos, span.start);
        TextSpan? textSpan;
        (textSpan, bracketCounter) = _formatBrackets(text, bracketCounter);
        textSpans.add(
          textSpan,
        );

        charPos = span.start;
      }

      // Add the span.
      var segment = code.substring(span.start, span.end);
      var style = theme._getStyle(span.scopes);
      textSpans.add(
        TextSpan(
          text: segment,
          style: style ?? TextStyle(),
          scopes: span.scopes,
        ),
      );

      charPos = span.end;
    }

    // Add any text after the last span.
    if (charPos < code.length) {
      var text = code.substring(charPos, code.length);
      TextSpan? textSpan;
      (textSpan, bracketCounter) = _formatBrackets(text, bracketCounter);
      textSpans.add(
        textSpan,
      );
    }

    return TextSpan(children: textSpans, style: theme._wrapper);
  }

  (TextSpan, int) _formatBrackets(String text, int bracketCounter) {
    var spans = <TextSpan>[];
    var plainText = '';
    for (var char in text.characters) {
      if (_isStartingBracket(char)) {
        if (plainText.isNotEmpty) {
          spans.add(TextSpan(text: plainText));
          plainText = '';
        }

        spans.add(TextSpan(
          text: char,
          style: _getBracketStyle(bracketCounter),
        ));
        bracketCounter += 1;
        plainText = '';
      } else if (_isEndingBracket(char)) {
        if (plainText.isNotEmpty) {
          spans.add(TextSpan(text: plainText));
          plainText = '';
        }

        bracketCounter -= 1;
        spans.add(TextSpan(
          text: char,
          style: _getBracketStyle(bracketCounter),
        ));
        plainText = '';
      } else {
        plainText += char;
      }
    }
    if (plainText.isNotEmpty) {
      spans.add(TextSpan(text: plainText));
    }

    if (spans.length == 1) {
      return (spans[0], bracketCounter);
    } else {
      return (TextSpan(children: spans), bracketCounter);
    }
  }

  TextStyle _getBracketStyle(int bracketCounter) {
    if (bracketCounter < 0) {
      return _failedBracketStyle;
    }
    return _bracketStyles[bracketCounter % _bracketStyles.length];
  }

  bool _isStartingBracket(String bracket) {
    return bracket == '{' || bracket == '[' || bracket == '(';
  }

  bool _isEndingBracket(String bracket) {
    return bracket == '}' || bracket == ']' || bracket == ')';
  }
}

/// A [HighlighterTheme] which is used to style the code.
class HighlighterTheme {
  final TextStyle _wrapper;
  TextStyle? _fallback;
  final _scopes = <String, TextStyle>{};
  Map<String, TextStyle> get scopes => _scopes;

  HighlighterTheme._({required TextStyle wrapper}) : _wrapper = wrapper;

  /// Load a [HighlighterTheme] from a JSON string.
  factory HighlighterTheme.fromConfiguration(
    String json,
    TextStyle defaultStyle,
  ) {
    final theme = HighlighterTheme._(wrapper: defaultStyle);
    theme._parseTheme(json);
    return theme;
  }

  /// Loads the default theme for the given [BuildContext].
  static Future<HighlighterTheme> loadForContext() {
    return loadDarkTheme();
  }

  /// Loads the default dark theme.
  static Future<HighlighterTheme> loadDarkTheme() async {
    return loadFromAssets(
      _defaultDarkThemeFiles,
      TextStyle(foreground: Color(0xFFB9EEFF)),
    );
  }

  /// Loads the default light theme.
  static Future<HighlighterTheme> loadLightTheme() async {
    return loadFromAssets(
      _defaultLightThemeFiles,
      TextStyle(foreground: Color(0xFF000088)),
    );
  }

  /// Loads a custom theme from a (list of) [jsonFiles] and a [defaultStyle].
  /// Pass in multiple [jsonFiles] to merge multiple themes.
  static Future<HighlighterTheme> loadFromAssets(
    List<String> jsonFiles,
    TextStyle defaultStyle,
  ) async {
    var theme = HighlighterTheme._(wrapper: defaultStyle);
    await theme._load(jsonFiles);
    return theme;
  }

  Future<void> _load(List<String> definitions) async {
    for (var definition in definitions) {
      _parseTheme(definition);
    }
  }

  void _parseTheme(String json) {
    var theme = jsonDecode(json);
    List settings = theme['settings'];
    for (Map setting in settings) {
      var style = _parseTextStyle(setting['settings']);

      var scopes = setting['scope'];
      if (scopes is String) {
        _addScope(scopes, style);
      } else if (scopes is List) {
        for (String scope in scopes) {
          _addScope(scope, style);
        }
      } else if (scopes == null) {
        _fallback = style;
      }
    }
  }

  TextStyle _parseTextStyle(Map setting) {
    Color? color;
    var foregroundSetting = setting['foreground'];
    if (foregroundSetting is String && foregroundSetting.startsWith('#')) {
      color = Color(
        int.parse(
              foregroundSetting.substring(1),
              radix: 16,
            ) |
            0xFF000000,
      );
    }

    var italic = false;
    var bold = false;
    var underline = false;

    var fontStyleSetting = setting['fontStyle'];
    if (fontStyleSetting is String) {
      if (fontStyleSetting == 'italic') {
        italic = true;
      } else if (fontStyleSetting == 'bold') {
        bold = true;
      } else if (fontStyleSetting == 'underline') {
        underline = true;
      } else {
        throw Exception('WARNING unknown style: $fontStyleSetting');
      }
    }

    return TextStyle(
      foreground: color ?? Color(0xFF000000),
      italic: italic,
      bold: bold,
      underline: underline,
    );
  }

  void _addScope(String scope, TextStyle style) {
    _scopes[scope] = style;
  }

  TextStyle? _getStyle(List<String> scope) {
    for (var s in scope) {
      var fallbacks = _fallbacks(s);
      for (var f in fallbacks) {
        var style = _scopes[f];
        if (style != null) {
          return style;
        }
      }
    }
    return _fallback;
  }

  List<String> _fallbacks(String scope) {
    var fallbacks = <String>[];
    var parts = scope.split('.');
    for (var i = 0; i < parts.length; i++) {
      var s = parts.sublist(0, i + 1).join('.');
      fallbacks.add(s);
    }
    return fallbacks.reversed.toList();
  }
}

class SpanVisitor {
  final Function(TextSpan node, int depth) visitor;
  SpanVisitor(this.visitor);

  visit(TextSpan root) {
    localVisit(TextSpan node, int depth) {
      visitor(node, depth);
      depth++;
      for (var child in node.children) {
        localVisit(child, depth);
      }
    }

    localVisit(root, 0);
  }
}
