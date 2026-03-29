library;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:tekartik_sembast_flutter/sembast_flutter.dart';

void main() {
  var factory = kIsWeb ? databaseFactoryWeb : databaseFactoryIo;
  test('simple', () async {
    var dbName = join('.local', 'test.db');
    await factory.deleteDatabase(dbName);
    var db = await factory.openDatabase(dbName);
    var store = intMapStoreFactory.store('test');
    await store.drop(db);
    await store.add(db, {'test': 'value'});
    expect((await store.query().getSnapshots(db)).first.value, {
      'test': 'value',
    });
    await db.close();
  });
}
