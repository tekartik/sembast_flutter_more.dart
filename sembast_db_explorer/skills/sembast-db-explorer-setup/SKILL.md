---
name: sembast-db-explorer-setup
description: >-
  Use when adding an in-app read-only browser for a sembast database to a
  Flutter app (a debug or developer menu entry that lists stores, records and
  record values): package:sembast_db_explorer/sembast_db_explorer.dart and its
  single entry point showDatabaseExplorer(context, database), what it shows
  (non-empty stores, live record list, pretty-printed record value), its
  Navigator/MaterialApp requirements and its limitations (read only, store list
  not refreshed).
---

# sembast_db_explorer: an in-app sembast database browser

`package:sembast_db_explorer` is a small Flutter package with exactly one
public function, `showDatabaseExplorer(context, database)`. It pushes a
read-only, three-level browser on the current `Navigator`: stores → records of
a store → value of a record. It is meant for a debug or developer menu, not
for end users.

## Guidelines

### Depending on it

* Not on pub.dev. Add it from git, normally as a `dev_dependency` or behind a
  debug-only flavor since it ships UI you do not want in a release build:
  ```yaml
  dependencies:
    sembast_db_explorer:
      git:
        url: https://github.com/tekartik/sembast_flutter_more.dart
        path: sembast_db_explorer
      version: '>=0.1.0'
  ```
  It pulls `sembast` and `tekartik_common_utils` (also a git dependency, on
  `https://github.com/tekartik/common_utils.dart`).
* It does not choose or open a database. Pass the `Database` your app already
  opened, from any factory (`databaseFactoryIo`, `databaseFactoryWeb`,
  `getDatabaseFactorySqflite(...)`, `tekartik_app_flutter_sembast`'s
  `getDatabaseFactory()`).

### Using it

* Single import: `package:sembast_db_explorer/sembast_db_explorer.dart`. It
  exports only `showDatabaseExplorer`; everything else (`DbData`,
  `DbHomeScreen`, `StoreHomeScreen`, `RecordHomeScreen`) is under `src/` and
  is not public API.
* Signature: `Future<void> showDatabaseExplorer(BuildContext context, Database
  database)`. It calls `Navigator.of(context).push(MaterialPageRoute(...))`, so
  the context must be below a `MaterialApp` (or at least a `Navigator` plus
  `Material`/`Directionality`) and must still be mounted. The returned future
  completes when the user pops back out of the explorer.
* Opening a database is asynchronous: check `mounted` (or capture the
  `NavigatorState`) before and after the `await`, then call
  `showDatabaseExplorer`.
* The explorer never opens, closes or deletes the database; keep it open for
  as long as the explorer is on screen and close it yourself afterwards.

### What it shows

* **Stores screen** (`Stores` title): the names returned by
  `getNonEmptyStoreNames(db)` (`package:sembast/utils/database_utils.dart`).
  Empty stores and stores that exist only as a `StoreRef` in your code are not
  listed; the main store appears as `_main` when it holds records.
  This list is read once in `initState`: it does **not** refresh while the
  screen is displayed. Pop and re-open the explorer after writing to a new
  store.
* **Store screen**: `store.query().onSnapshots(db)`, so the record list is
  live — added, updated and deleted records appear immediately. Each tile
  shows `record.key.toString()`; there is no filter, sort or paging, so a
  store with many thousands of records is slow to browse.
* **Record screen**: `record.onSnapshot(db)`, live, showing the value
  pretty-printed with `jsonPretty` from `tekartik_common_utils`, falling back
  to `toString()` when the value is not json encodable. A record that does not
  exist (or is deleted while displayed) leaves a progress indicator, because
  the snapshot is `null`.
* It is strictly read-only: no editing, no adding, no deleting, no export, no
  search. Use the sembast API (or `exportDatabase` from
  `package:sembast/utils/sembast_import_export.dart`) for those.

### Keeping it out of release builds

* Guard the menu entry with `kDebugMode` (`package:flutter/foundation.dart`)
  or your own flavor flag so the explorer screens are tree-shaken from a
  production build.
* `tekartik_app_dev_menu` is the usual host for this kind of entry in Tekartik
  apps; a plain `ListTile` in a debug screen works just as well.

## Examples

### Minimal app showing the explorer

```dart
import 'package:flutter/material.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_db_explorer/sembast_db_explorer.dart';

void main() => runApp(const ExplorerApp());

class ExplorerApp extends StatelessWidget {
  const ExplorerApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: HomePage(title: 'Db explorer example'));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _showExplorer() async {
    var db = await databaseFactoryIo.openDatabase(
      'sembast_db_explorer_app.db',
      version: 2,
      onVersionChanged: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await intMapStoreFactory.store('test').add(db, {'test': 1});
        }
      },
    );
    // The context must still be mounted after the await.
    if (mounted) {
      await showDatabaseExplorer(context, db);
    }
    await db.close();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    floatingActionButton: FloatingActionButton(
      onPressed: _showExplorer,
      tooltip: 'Show explorer',
      child: const Icon(Icons.view_array),
    ),
  );
}
```

### Debug-menu entry on the app database

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_db_explorer/sembast_db_explorer.dart';

/// Add to a debug screen; hidden in release builds.
class DatabaseExplorerTile extends StatelessWidget {
  const DatabaseExplorerTile({super.key, required this.database});

  /// The database the app already opened; the explorer never closes it.
  final Database database;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    return ListTile(
      leading: const Icon(Icons.storage),
      title: const Text('Explore database'),
      onTap: () => showDatabaseExplorer(context, database),
    );
  }
}
```

### Opening lazily, safe across the async gap

```dart
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_db_explorer/sembast_db_explorer.dart';

/// Opens the database, browses it, then closes it again.
///
/// Capture the navigator context before awaiting, or re-check `mounted` in a
/// State; a disposed context makes Navigator.of throw.
Future<void> exploreDatabase(
  BuildContext context,
  DatabaseFactory factory,
  String path,
) async {
  var navigatorContext = Navigator.of(context).context;
  var db = await factory.openDatabase(path);
  try {
    // Only non-empty stores are listed, and the list is not refreshed while
    // the explorer is open.
    await showDatabaseExplorer(navigatorContext, db);
  } finally {
    await db.close();
  }
}
```

## Common mistakes

* Calling `showDatabaseExplorer` with a context that has no `Navigator`
  ancestor (above `MaterialApp`, or a context disposed during an `await`).
* Expecting a store you just declared with `StoreRef(...)` to be listed: only
  stores that currently hold records appear.
* Expecting the store list to update live: it is read once per visit to the
  stores screen; the record list and the record value are live.
* Expecting to edit or delete records from the explorer: it is read-only.
* Closing the database while the explorer is displayed; the live snapshot
  streams then fail.
* Shipping the entry point in a release build instead of guarding it with
  `kDebugMode` or a flavor.
