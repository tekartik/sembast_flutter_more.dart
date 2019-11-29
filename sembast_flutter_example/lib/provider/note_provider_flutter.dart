import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast_flutter_example/provider/note_provider.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_sembast_flutter/sembast_flutter.dart';

class DbNoteProviderFlutter extends DbNoteProvider {
  Directory directory;
  DbNoteProviderFlutter() : super(databaseFactoryIo);

  @override
  Future<String> fixPath(String path) async {
    // devPrint('/notepad fixing: $path');
    if (directory == null) {
      await lock.synchronized(() async {
        if (directory == null) {
          try {
            // devPrint('/notepad fixing: $path');
            directory = await getApplicationDocumentsDirectory();
          } catch (e) {
            print('/notepad fixPath: $e');
          }
          // Make sure it exists
          try {
            await directory.create(recursive: true);
          } catch (_) {}
        }
      });
    }

    return join(directory.path, path);
  }
}
