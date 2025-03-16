import 'package:jaspr/ui.dart';
import 'package:lcov_format/lcov.dart';
import 'package:path/path.dart' as pth;
import 'package:jaspr/jaspr.dart';
import 'package:logging/logging.dart';

class FileList extends StatelessComponent {
  static final log = Logger('file_list');

  final List<({String path, LcovRecord record})> files;

  final void Function(String file) fileSelected;

  FileList(this.files, this.fileSelected);

/*
  0. Keep track of lcov stats for all directories.
  1. Collapse directories with only one child to a single row
  2. then yield flex row with space-between for progress bar.
*/
  @override
  Iterable<Component> build(BuildContext context) sync* {
    final root = Node('');

    // Collect
    for (var item in files) {
      final segments = pth.split(item.path);
      log.info('segments: $segments');
      var following = root.children;
      root
        ..linesFound += item.record.linesFound
        ..linesHit += item.record.linesHit;

      late Node node;
      for (int i = 0; i < segments.length; i++) {
        final segment = segments[i];
        node = (following[segment] ??= Node(segment));
        node
          ..linesFound += item.record.linesFound
          ..linesHit += item.record.linesHit
          ..depth = i;
        following = node.children;
      }
      node.fullPath = item.path;
    }

    // Reduce
    reduce(Node node) {
      if (node.isLeaf) return;
      if (node.isSingular && !node.children.values.first.isLeaf) {
        final child = node.children.values.first;
        node.children.clear();
        node.part = '${node.part}/${child.part}';
        node.children.addAll(child.children);
        return reduce(node);
      }
      if (!node.isSingular) {
        for (final child in node.children.values) {
          reduce(child);
        }
      }
    }

    reduce(root);

    // Yield
    Iterable<Component> produce(Node node) sync* {
      final percent = node.linesHit / node.linesFound * 100;
      yield div(classes: 'file-line', [
        span([
          text('${'   ' * node.depth}${node.isLeaf ? '🎯' : '📂'} ${node.part}')
        ], styles: Styles(whiteSpace: WhiteSpace.pre)),
        div([
          span([text('${node.linesHit} / ${node.linesFound} ')]),
          progress([text('${percent.toStringAsFixed(2)}%')],
              max: 100,
              value: percent,
              styles: Styles(raw: {
                '--color': 'color-mix(in srgb, red, green $percent%)'
              })),
        ], classes: 'progress'),
      ], events: {
        if (node.isLeaf) 'click': (_) => fileSelected(node.fullPath!)
      });
      for (final child in node.children.values) {
        yield* produce(child);
      }
    }

    yield* produce(root);

    log.info('root: $root');
  }
}

class Node {
  String part;
  String? fullPath;
  int depth = 0;

  final children = <String, Node>{};

  bool get isLeaf => children.isEmpty;
  bool get isSingular => children.length == 1;

  int linesHit = 0;
  int linesFound = 0;

  Node(this.part);

  @override
  String toString() => isLeaf
      ? '🎯 $part: $linesHit / $linesFound'
      : '📂 $part: $linesHit / $linesFound\n${[...children.values].join('\n')}';
}
