import 'dart:async';

import 'package:path/path.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/timestamp.dart';
import 'package:sembast_dev_menu/sembast_dev_menu.dart';

import 'package:tekartik_app_cv_sembast/app_cv_sembast.dart';
import 'package:tekartik_app_dev_menu/dev_menu.dart';

Future<void> main(List<String> args) async {
  var db = await databaseFactoryIo.openDatabase(
    join('.local', 'cv_sembast_menu', 'main.db'),
  );
  await mainMenu(args, () {
    cvSembastDatabaseDevMenu(SembastDatabaseDevMenuContext(database: db));
    leave(() async {
      await db.close();
    });
  });
}

class DbTestRecord extends DbStringRecordBase {
  final name = CvField<String>('name');
  final timestamp = CvField<Timestamp>('timestamp');
  @override
  CvFields get fields => [name, timestamp];
}

var store = cvStringStoreFactory.store<DbTestRecord>('test');
void cvSembastDatabaseDevMenu(SembastDatabaseDevMenuContext context) {
  cvAddConstructors([DbTestRecord.new]);
  late Database db;
  enter(() async {
    db = context.database;
  });
  leave(() async {});
  item('add', () async {
    var record = await store.add(
      db,
      DbTestRecord()..timestamp.v = Timestamp.now(),
    );
    write(record.dbToJsonPretty());
  });
  item('clear all', () async {
    await store.delete(db);
  });
  item('list', () async {
    var records = await store.find(db);

    for (var record in records) {
      write(record.dbToJsonPretty());
    }
    if (records.isEmpty) {
      write('no records');
    } else {
      write('${records.length} records');
    }
  });
  StreamSubscription? subscription;
  item('register on latest', () async {
    subscription = store
        .query(
          finder: Finder(
            sortOrders: [SortOrder(DbTestRecord().timestamp.key, false)],
          ),
        )
        .onRecord(db)
        .listen((record) {
          var diff = Timestamp.now().difference(
            record?.timestamp.v ?? Timestamp.zero,
          );
          write(
            'latest record: ${Timestamp.now().toIso8601String()} $diff ${record?.dbToJsonPretty()}',
          );
        });
  });
  item('cancel on latest', () async {
    await subscription?.cancel();
    subscription = null;
  });
}
