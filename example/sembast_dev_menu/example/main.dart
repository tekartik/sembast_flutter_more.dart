import 'package:sembast/sembast_io.dart';
import 'package:sembast_dev_menu/sembast_dev_menu.dart';
import 'package:tekartik_app_dev_menu/dev_menu.dart';

void main(List<String> args) {
  mainMenu(args, () {
    sembastDevMenu(
      SembastDevMenuContext(
        databaseFactory: databaseFactoryIo,
        databaseDir: '.local/main_io',
      ),
    );
  });
}
