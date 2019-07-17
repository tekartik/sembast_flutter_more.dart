import 'dart:io';

import 'package:path/path.dart';

Future main() async {
  var src = '../../sembast.dart/sembast/test';
  var dst = 'test';

  Future copy(String file) async {
    var dstFile = join(dst, file);
    await Directory(dirname(dstFile)).create(recursive: true);
    await File(join(src, file)).copy(join(dst, file));
  }

  Future copyAll(List<String> files) async {
    for (var file in files) {
      print(file);
      await copy(file);
    }
  }

  var list = Directory(src)
      .listSync(recursive: false)
      .map((entity) => basename(entity.path))
      .where((path) => FileSystemEntity.isFileSync(join(src, path)))

   //
  ;
  print(list);
  await copyAll([
    ...list,
    join('src', 'test_defs.dart')
  ]);
}
