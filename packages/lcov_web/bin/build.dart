import 'dart:io';
import 'package:archive/archive_io.dart';

void main() async {
  stdout.writeln('building app');
  var process =
      await Process.start('jaspr', ['build', '--verbose'], runInShell: true);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  var error = await process.exitCode;
  if (error != 0) {
    stderr.writeln('ERROR building tree ($error)');
    exit(1);
  }

  // 'build/` exists; but we want to package specific files.
  stdout.writeln('[zip] creating web.zip');
  final archive = Archive();
  for (var filename in ['index.html', 'main.dart.js', 'styles.css']) {
    stdout.writeln('[zip] adding $filename');
    final file = File('build/jaspr/$filename');
    final fileStream = InputFileStream(file.path);
    final archiveFile = ArchiveFile.stream(filename, fileStream)
      ..lastModTime = file.lastModifiedSync().millisecondsSinceEpoch ~/ 1000
      ..mode = file.statSync().mode;
    archive.addFile(archiveFile);
  }
  stdout.writeln('[zip] compressing');
  final bytes = BZip2Encoder().encodeBytes(TarEncoder().encodeBytes(archive));
  File('web.tar.bz2').writeAsBytesSync(bytes);
}
