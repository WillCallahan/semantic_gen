import 'dart:io';

import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  final target = args.isNotEmpty ? args.first : '.';
  final glob = Glob('**/*.rewritten.dart');

  await for (final file in glob.list(root: target)) {
    if (file is File) {
      final rewrittenFile = file as File;
      final originalPath =
          p.withoutExtension(rewrittenFile.path) + '.dart';
      final originalFile = File(originalPath);

      await originalFile.writeAsString(await rewrittenFile.readAsString());
      await rewrittenFile.delete();

      print('Applied changes to ${p.relative(originalPath)}');
    }
  }
}
