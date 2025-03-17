import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/args.dart';
import 'package:crypto/crypto.dart';
import 'package:lcov_format/formatters_io.dart';
import 'package:lcov_format/lcov.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as path;

main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('format',
        abbr: 'f',
        allowed: ['stats', 'html', 'ansi'],
        defaultsTo: 'stats',
        help: 'control format output')
    ..addMultiOption('lcov', abbr: 'l', help: 'lcov file(s)')
    ..addOption('out', abbr: 'o', help: 'output path if format is not stats / ansi')
    ..addOption('src', abbr: 's', help: 'source folder for code lookup')
    ..addFlag('help', abbr: 'h', help: 'this help text');

  final List<String> files;
  final String? outputFolder;
  final String format;

  try {
    final options = parser.parse(args);
    files = options['lcov'] as List<String>;
    if (files.isEmpty) throw 'Missing --lcov';
    format = options['format'];
    outputFolder = options['out'];

    if (options.wasParsed('help')) {
      stderr.writeln('Usage: ');
      for (final line in LineSplitter.split(parser.usage)) {
        stderr.writeln('  $line');
      }
      exit(0);
    }

    if (options['format'] == 'html' && !options.wasParsed('out')) {
      throw 'missing --out parameter';
    }
  } catch (e) {
    stderr.writeln('Error: $e');
    stderr.writeln('Usage: ');
    for (final line in LineSplitter.split(parser.usage)) {
      stderr.writeln('  $line');
    }
    exit(1);
  }

  final root = LcovNode(path: '');

  for (final file in files) {
    final node = LcovParser().parse(File(file).readAsStringSync()).replace(newPath: file);
    root.children[file] = node;
    root
      ..linesFound += node.linesFound
      ..linesHit += node.linesHit;
  }

  switch (format) {
    case 'stats':
      stdoutFormat(root);

    case 'ansi':
      await ansiFormat(root);

    case 'html':
      await handleHtml(root, outputFolder!);
      break;
  }
}

handleHtml(LcovNode node, String outPath) async {
  // [x] parse lcov
  // [x] ] convert lcov to js content
  // [x] copy precompiled jaspr to output folder.
  // profit?

  // create the output folder if its missing - but we're not going to overwrite
  // anything as the user might have other data already there (like lcov)
  await Directory(outPath).create(recursive: true);

  // If we're globally activated; start looking there.
  final packageConfig = await findPackageConfigUri(Platform.script);
  if (packageConfig == null) throw 'package config lookup failed';
  final package = packageConfig['lcov_format'];
  if (package == null) throw 'package config error';
  final packageUri = package.root;

  final webFile = File.fromUri(
      packageUri.replace(pathSegments: [...packageUri.pathSegments, 'assets', 'web.tar.bz2']));
  final archive = TarDecoder().decodeBytes(BZip2Decoder().decodeBytes(webFile.readAsBytesSync()));
  extractArchiveToDiskSync(archive, outPath);

  final index = {};
  // highlights has all the files and could be... a lot
  await jsonFormat(node, (fileNode, record) async {
    final split = path.split(record.fullPath);
    if (split.first == '.') {
      split.removeAt(0);
    }
    final fullPath = split.join('/');
    final pathHex = '${md5.convert(utf8.encode(fullPath))}';

    /*
      To load data:
        <script src="root.js"></script>
        <script src="00d1308570ff8b8bdff510975e7c88f2.js"></script>
      Then decompress the base64 string using gzip
    */
    final compressedString = base64.encode(gzip.encode(json.encode(record.highlight).codeUnits));
    File(path.join(outPath, '$pathHex.js'))
        .writeAsStringSync("window.lcov_data_$pathHex = '$compressedString';");
    index[fullPath] = {
      'highlights': '$pathHex.js',
      'lcov': record.lcov,
    };
  });

  final compressedString = base64.encode(gzip.encode(json.encode(index).codeUnits));

  File(path.join(outPath, 'root.js'))
      .writeAsStringSync("window.lcov_data_root = '$compressedString';");
  //File(path.join(outPath, 'root.json')).writeAsStringSync("window.lcov_data_root = '${json.encode(index)}';");
}

stdoutFormat(LcovNode node) {
  LcovVisitor((node, depth) {
    print(
        '${'  ' * depth}${node.path} [${node.linesHit}/${node.linesFound}] ${node.linesHit / node.linesFound * 100.0}%');
  }).visit(node);
}
