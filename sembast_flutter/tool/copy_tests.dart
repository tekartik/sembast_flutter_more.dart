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
      await copy(file);
    }
  }

  await copyAll([
    'doc_test.dart',
    'test_common.dart',
    'field_test.dart',
    //'io_test_common.dart',
    'encrypt_codec.dart',
    'encrypt_codec_test.dart',
    join('src', 'test_defs.dart')
  ]);
}
