import 'dart:convert';
import 'package:path/path.dart' as pth;

class LcovParser {
  LcovNode parse(String content, {String parent = ''}) {
    final lines = LineSplitter.split(content);

    String filePath = '';
    var hits = <int, int>{};
    int linesHit = -1;
    int linesFound = -1;

    final root = LcovNode(path: '');

    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('SF:')) {
        if (filePath.isNotEmpty) throw 'extra SF record';
        filePath = line.substring(3);
      } else if (line.startsWith('DA:')) {
        final match = line.substring(3).split(',');
        hits[int.parse(match.first)] = int.parse(match[1]);
      } else if (line.startsWith('LH:')) {
        final match = line.substring(3).split(',');
        if (linesHit != -1) throw 'extra LH record';
        linesHit = int.parse(match.first);
      } else if (line.startsWith('LF:')) {
        final match = line.substring(3).split(',');
        if (linesFound != -1) throw 'extra LF record';
        linesFound = int.parse(match.first);
      } else if (line == 'end_of_record') {
        if (filePath == '') throw 'invalid SF path';
        final segments = pth.split(filePath);
        var currentNode = root;
        var lastSegment = segments.last;
        final nodes = <LcovNode>[root];
        if (segments.length > 1) {
          segments.length -= 1;
          for (final segment in segments) {
            currentNode = currentNode.children.putIfAbsent(segment, () => LcovNode(path: segment));
            nodes.add(currentNode);
          }
        }
        final record = LcovRecord(
          path: filePath,
          content: '', // file content
          linesFound: linesFound,
          linesHit: linesHit,
          lines: hits,
        );
        currentNode.children[lastSegment] = record;

        for (var node in nodes) {
          node
            ..linesFound += record.linesFound
            ..linesHit += record.linesHit;
        }

        // clear memory
        filePath = '';
        hits = <int, int>{};
        linesHit = -1;
        linesFound = -1;
      }
    }
    return root;
  }
}

class LcovNode {
  final String path;
  final children = <String, LcovNode>{};

  int linesFound;
  int linesHit;

  num get percent => (linesHit / linesFound) * 100;

  LcovNode({
    required this.path,
    this.linesFound = 0,
    this.linesHit = 0,
  });

  add(LcovNode node) {
    children[node.path] = node;
    linesFound += node.linesFound;
    linesHit += node.linesHit;
  }

  LcovNode.fromJson(Map<String, dynamic> json)
      : linesFound = json['lf'] ?? 0,
        linesHit = json['lh'] ?? 0,
        path = json['p'];

  String get simpleReport => '$path:\t[$linesHit/$linesFound] = ${linesHit / linesFound * 100}%';

  LcovNode replace({required String newPath}) => LcovNode(path: newPath)
    ..linesFound = linesFound
    ..linesHit = linesHit
    ..children.addAll(children);

  Map<String, dynamic> toJson() => {
        'p': path,
        'lf': linesFound,
        'lh': linesHit,
      };

  void clear() {
    children.clear();
    linesFound = linesHit = 0;
  }
}

final class LcovRecord extends LcovNode {
  final String content;
  final Map<int, int> lines;

  LcovRecord({
    required super.path,
    required super.linesFound,
    required super.linesHit,
    required this.content,
    required this.lines,
  });

  LcovRecord.fromJson(super.json)
      : content = '',
        lines = {for (int i = 0; i < json['l'].length; i += 2) json['l'][i]: json['l'][i + 1]},
        super.fromJson();

  @override
  String get simpleReport => '$path:\t[$linesHit/$linesFound] = ${linesHit / linesFound * 100}%';

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'l': [
          for (var MapEntry(:key, :value) in lines.entries) ...[key, value],
        ],
      };
}

class LcovVisitor {
  final Function(LcovNode node, int depth) visitor;
  LcovVisitor(this.visitor);

  visit(LcovNode root) {
    insideVisit(LcovNode node, int depth) {
      visitor(node, depth);
      depth++;
      for (var child in node.children.values) {
        insideVisit(child, depth);
      }
    }

    insideVisit(root, 0);
  }
}
