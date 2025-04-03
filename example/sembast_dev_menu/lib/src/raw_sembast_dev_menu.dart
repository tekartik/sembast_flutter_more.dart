// TODO: Put public facing types in this file.
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sembast/blob.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/timestamp.dart';
import 'package:sembast_dev_menu/sembast_dev_menu.dart';
import 'package:tekartik_app_dev_menu/dev_menu.dart';

Future<void> main(List<String> args) async {
  var dir = join('.local', 'raw_sembast_dev_menu');

  await mainMenu(args, () {
    rawSembastDevMenu(
      SembastDevMenuContext(
        databaseFactory: databaseFactoryIo,
        databaseDir: dir,
      ),
    );
  });
}

var store = intMapStoreFactory.store('test');

void rawSembastDevMenu(SembastDevMenuContext context) {
  var factory = context.databaseFactory;
  leave(() async {});
  var dbName = context.fixPath('test.db');
  Database? db;
  Future<Database> openDb() async {
    return db ??= await factory.openDatabase(dbName);
  }

  Future<void> closeDb() async {
    if (db != null) {
      await db!.close();
      db = null;
    }
  }

  item('delete db', () async {
    await factory.deleteDatabase('test.db');
  });
  item('open db', () async {
    await openDb();
  });
  item('close db', () async {
    await closeDb();
  });
  item('clear item', () async {});
  item('add item', () async {
    var db = await openDb();
    var key = await store.add(db, {'timestamp': Timestamp.now()});
    write('key $key');
  });
  item('add all types item', () async {
    var map = <String, Object?>{
      'int': 1,
      'double': 1.0,
      'string': 'one',
      'bool': true,
      'list': [1, 2, 3],
      'map': {'one': 1},
      'timestamp': Timestamp.now(),
      'blob': Blob(Uint8List.fromList([1, 2, 3])),
      'complex': [
        1,
        {
          'sub': [
            '3',
            [
              [
                {
                  'deep': {'sub': 'value'},
                },
              ],
            ],
          ],
        },
      ],
    };
    var db = await openDb();
    var key = await store.add(db, map);
    write('key $key');
  });
  item('delete first item', () async {
    var db = await openDb();
    var count = await store.delete(db, finder: Finder(limit: 1));
    write('deleted $count');
  });
  item('list item', () async {
    var db = await openDb();
    var list = await store.find(db);
    for (var item in list) {
      write('${item.key}: ${item.value}');
    }
  });
}
