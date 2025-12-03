import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

Future<void> main() async {
  final aGlob = Glob('**.dart');
  await aGlob.list().drain<void>();
}
