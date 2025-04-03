import 'package:sembast_dev_menu/sembast_dev_menu.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:tekartik_app_dev_menu/dev_menu.dart';

void main(List<String> args) {
  mainMenu(args, () {
    sembastDevMenu(
      SembastDevMenuContext(
        databaseFactory: databaseFactoryWeb,
        databaseDir: 'sembast_dev_menu_web',
      ),
    );
  });
}
