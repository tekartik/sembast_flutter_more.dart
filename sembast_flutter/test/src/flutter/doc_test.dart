library sembast.flutter.doc_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

void main() {
  group('flutter_doc', () {
    test('open', () async {
      try {
        // get the application directory
        var dir = await getApplicationDocumentsDirectory();
        // make sure it exists
        await dir.create(recursive: true);
        // build the database path
        var dbPath = join(dir.path, 'my_database.db');
        // open the database
        var db = await databaseFactoryIo.openDatabase(dbPath);

        await db.close();
      } catch (_) {}
    });
  });
}
