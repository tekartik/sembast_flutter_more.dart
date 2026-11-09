# sembast_db_explorer

A read-only browser of a [sembast](https://pub.dev/packages/sembast) database
inside a Flutter app, for a debug or developer menu: the stores, the records of
a store (live), the value of a record (pretty printed json, live). One
function: `showDatabaseExplorer(context, database)`.

## Getting started

Not on pub.dev, a git dependency:

```yaml
dependencies:
  sembast_db_explorer:
    git:
      url: https://github.com/tekartik/sembast_flutter_more.dart
      path: sembast_db_explorer
```

```dart
import 'package:material_ui/material_ui.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_db_explorer/sembast_db_explorer.dart';

/// A debug menu entry on the database the app already opened.
Widget exploreTile(BuildContext context, Database database) => ListTile(
  title: const Text('Explore the database'),
  onTap: () => showDatabaseExplorer(context, database),
);
```

[example/main.dart](example/main.dart) runs it on a sample database in memory
(`flutter run example/main.dart`).

### Platforms

Every Flutter platform, web included, with any sembast factory (io, web,
sqflite, memory): give it the `Database` the app opened. The explorer never
opens, closes or deletes it.

## Common mistakes

* The screens are built on `package:material_ui`: the app must use material_ui's
  `MaterialApp` (`import 'package:material_ui/material_ui.dart'`). Under
  Flutter's own `MaterialApp`, opening the explorer fails with "No
  MaterialLocalizations found".
* The store list (non empty stores only, `_main` for the main store) is read
  when the explorer opens: reopen it after writing to a new store.
* A store of many thousands of records is slow: every record is listed, no
  paging.
* Keep it out of release builds (`kDebugMode` or a flavor).

Agent skill: [sembast-db-explorer-setup](skills/sembast-db-explorer-setup/SKILL.md).
