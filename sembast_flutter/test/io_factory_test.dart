@TestOn('vm')
library sembast_flutter.test.io_factory_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_test/all_fs_test.dart' as all_fs_test;
import 'package:sembast_test/all_test.dart';
import 'package:sembast_test/io_test_common.dart';

void main() {
  var context = databaseContextIo;
  all_fs_test.defineTests(context);
  defineTests(databaseContextIo);

  test('add', () async {
    var store = intMapStoreFactory.store();
    var db = await databaseContextIo.open('.dart_tool/test.db');
    await store.drop(db);
    await store.add(
      db,
      {'test': 'value'},
    );
    expect(
        (await store.query().getSnapshots(db)).first.value, {'test': 'value'});
  });
}
