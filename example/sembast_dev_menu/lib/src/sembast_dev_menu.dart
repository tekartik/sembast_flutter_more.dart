// TODO: Put public facing types in this file.

import 'package:path/path.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_dev_menu/sembast_dev_menu.dart';
import 'package:tekartik_app_dev_menu/dev_menu.dart';

Future<void> main(List<String> args) async {
  var dir = join('.local', 'sembast_dev_menu');

  await mainMenu(args, () {
    sembastDevMenu(
      SembastDevMenuContext(
        databaseFactory: databaseFactoryIo,
        databaseDir: dir,
      ),
    );
  });
}

var store = intMapStoreFactory.store('test');

class SembastDevMenuContext {
  final DatabaseFactory databaseFactory;
  final String? databaseDir;

  String fixPath(String path) {
    if (databaseDir == null) {
      return path;
    }
    return join(databaseDir!, path);
  }

  SembastDevMenuContext({this.databaseDir, required this.databaseFactory});

  SembastDevMenuContext childContext(String path) => SembastDevMenuContext(
    databaseFactory: databaseFactory,
    databaseDir: fixPath(path),
  );
}

class SembastDatabaseDevMenuContext {
  final Database database;

  SembastDatabaseDevMenuContext({required this.database});
  Future<void> close() async {
    await database.close();
  }
}

void sembastDevMenu(SembastDevMenuContext context) {
  menu('raw', () {
    rawSembastDevMenu(context.childContext('raw'));
  });
  item('menu cv', () async {
    var db = await context.databaseFactory.openDatabase(
      context.childContext('cv').fixPath('main.db'),
    );
    await showMenu(() {
      cvSembastDatabaseDevMenu(SembastDatabaseDevMenuContext(database: db));
    });
  });
}
