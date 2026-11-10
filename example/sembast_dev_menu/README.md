# sembast dev menu

An example dev menu (tekartik_app_dev_menu) exercising sembast by hand: a raw
store (add, list, delete, all value types: `Timestamp`, `Blob`, nested
lists and maps) and cv records (tekartik_app_cv_sembast: add, list, a
singleton record, `onRecord` listeners). The same menu runs in a console
(io) and in a browser (sembast_web).

## Run

From this folder (`dart pub get` first):

```sh
dart run example/main.dart                    # console, io databases
dart run example/main.dart 0 4 7 . .          # raw > add item, list item, exit
dart pub global run webdev serve web:8080     # browser, sembast_web databases
dart test                                     # the raw menu, run by arguments
```

- Console: type the number of an entry, `.` goes back (and exits from the
  top menu), `?` shows the menu again; arguments are typed first.
- Databases: `.local/main_io/raw/test.db` and `.local/main_io/cv/main.db`
  under the working directory (io), `sembast_dev_menu_web/...` in the
  browser IndexedDB.
- `lib/src/*_dev_menu.dart` each have their own `main` too
  (`dart run lib/src/raw_sembast_dev_menu.dart`, databases in `.local/`).

## Use it in another menu

```yaml
dependencies:
  sembast_dev_menu:
    git:
      url: https://github.com/tekartik/sembast_flutter_more.dart
      path: example/sembast_dev_menu
```

```dart
import 'package:sembast/sembast_io.dart';
import 'package:sembast_dev_menu/sembast_dev_menu.dart';
import 'package:tekartik_app_dev_menu/dev_menu.dart';

Future<void> main(List<String> arguments) async {
  await mainMenu(arguments, () {
    menu('sembast', () {
      sembastDevMenu(
        SembastDevMenuContext(
          databaseFactory: databaseFactoryIo,
          databaseDir: '.local/sembast_menu',
        ),
      );
    });
  });
}
```

New local database code uses sdb (`package:idb_shim/sdb.dart`): this menu is
for sembast itself.
