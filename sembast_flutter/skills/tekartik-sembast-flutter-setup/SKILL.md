---
name: tekartik-sembast-flutter-setup
description: >-
  Use when adding a sembast database to a Flutter app that must run on mobile,
  desktop AND web with a single import: package:tekartik_sembast_flutter
  (tekartik_sembast_flutter), sembast_flutter.dart, which re-exports
  sembast_io.dart and sembast_web.dart so databaseFactoryIo,
  createDatabaseFactoryIo, databaseFactoryWeb, databaseFactoryWebWorker and the
  whole sembast API (Database, DatabaseFactory, StoreRef, Finder, Filter) come
  from one place; choosing the factory with kIsWeb, resolving the path with
  path_provider on native and an IndexedDB name on the web, and running
  flutter test on vm, chrome and wasm.
---

# tekartik_sembast_flutter: one sembast import for every Flutter target

`package:tekartik_sembast_flutter` is a thin convenience package. Its single
library, `sembast_flutter.dart`, is only:

```dart
export 'package:sembast/sembast_io.dart';
export 'package:sembast_web/sembast_web.dart';
```

Both of those are safe to import on every platform (the platform-specific
getters throw only when accessed on the wrong one), so one import gives a
Flutter app the io factory, the web factory and the whole sembast API. It adds
no code of its own; the repository exists to CI-test sembast in a Flutter
context (VM, dart2js and WASM).

## Guidelines

### Depending on it

* Not on pub.dev. Add it from git:
  ```yaml
  dependencies:
    tekartik_sembast_flutter:
      git:
        url: https://github.com/tekartik/sembast_flutter_more.dart
        path: sembast_flutter
  ```
  It brings `sembast`, `sembast_web` and `path`. Declare `sembast` yourself
  only if you import `package:sembast/timestamp.dart`,
  `package:sembast/blob.dart`, `package:sembast/utils/...` — those are not
  re-exported.
* Use it instead of depending on `sembast` + `sembast_web` and writing a
  conditional import just to pick a factory. If you need the sqflite backend
  (multi-process safety, very large databases), depend on `sembast_sqflite`
  instead; this package does not cover it. `tekartik_app_flutter_sembast`
  (in `app_flutter_utils.dart`) is the heavier alternative that also resolves
  the path for you.

### Import and factory choice

* One import: `package:tekartik_sembast_flutter/sembast_flutter.dart`. It
  exposes `databaseFactoryIo`, `createDatabaseFactoryIo({rootPath})`,
  `databaseFactoryWeb`, `databaseFactoryWebWorker` and everything in
  `package:sembast/sembast.dart` (`Database`, `DatabaseFactory`, `StoreRef`,
  `intMapStoreFactory`, `stringMapStoreFactory`, `Finder`, `Filter`,
  `SortOrder`, `SembastCodec`, `DatabaseMode`…).
* Pick the factory with `kIsWeb` from `package:flutter/foundation.dart`:
  `kIsWeb ? databaseFactoryWeb : databaseFactoryIo`. Accessing the wrong one
  throws `UnimplementedError` at runtime, so keep the choice in one place.
* In a web worker use `databaseFactoryWebWorker`, not `databaseFactoryWeb`.
* `databaseFactoryIo` is the plain sembast file backend (one JSON-lines file
  per database), not sqflite. It is fine for a single process; it is not
  cross-process safe.

### Paths

* On the web the argument of `openDatabase` is an **IndexedDB name** scoped to
  the origin, not a file path. `getApplicationSupportDirectory()` does not
  exist there.
* On native, `databaseFactoryIo` resolves a relative path against the process
  current directory, which is not a writable app location on a device. Build
  an absolute path with `path_provider` (`getApplicationSupportDirectory()` or
  `getApplicationDocumentsDirectory()`), create the directory, then join the
  name with `package:path`.
* `package:path_provider` imports `dart:io` and cannot be compiled for the
  web, so the path helper — not the factory — is what needs a conditional
  import (`db_path_stub.dart if (dart.library.js_interop) db_path_web.dart
  if (dart.library.io) db_path_io.dart`). Keep `path_provider` out of any
  file reachable from a web build.
* `createDatabaseFactoryIo(rootPath: ...)` sandboxes every database of that
  factory under one directory; handy for tests and desktop tools, still needs
  a writable root on a device.

### Testing

* `flutter test` runs on the Dart VM: `databaseFactoryIo` works and writes
  next to the package. Use a throwaway directory (`.local/`, `.dart_tool/`)
  and `deleteDatabase` before each test.
* `flutter test --platform chrome` and `flutter test --platform chrome --wasm`
  exercise `databaseFactoryWeb`; the package ships
  `tool/run_vm_test_flutter.dart`, `tool/run_dart2js_test_flutter.dart` and
  `tool/run_wasm_test_flutter.dart` that just run those three commands.
* Write the test factory the same way as the app (`kIsWeb ? ... : ...`) so the
  same test file runs on the three targets.
* `flutter test` uses `package:flutter_test`; do not import
  `package:test/test.dart` in the same file.
* Web caveats still apply (they come from `sembast_web`): `int`/`String` keys
  only, JavaScript number precision above 2^53, transactions that may be
  re-run and must stay idempotent, no `DateTime`/`Uint8List` values (use
  `Timestamp`/`Blob`), browser storage quotas.

## Examples

### The application database, one file for every platform

```dart
import 'package:flutter/foundation.dart';
import 'package:tekartik_sembast_flutter/sembast_flutter.dart';

/// databaseFactoryWeb on the web, databaseFactoryIo on mobile and desktop.
final DatabaseFactory appDatabaseFactory = kIsWeb
    ? databaseFactoryWeb
    : databaseFactoryIo;

final notesStore = intMapStoreFactory.store('notes');

/// [path] is an absolute file path on native, an IndexedDB name on the web.
Future<Database> openAppDatabase(String path) =>
    appDatabaseFactory.openDatabase(path, version: 1);

Future<List<String>> notesTitles(Database db) async {
  var records = await notesStore.find(
    db,
    finder: Finder(
      filter: Filter.notEquals('archived', true),
      sortOrders: [SortOrder('title')],
    ),
  );
  return records.map((r) => r.value['title'] as String).toList();
}
```

### Native path helper (`lib/db/db_path_io.dart`)

```dart
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tekartik_sembast_flutter/sembast_flutter.dart';

/// Reached through a conditional import: path_provider pulls dart:io and
/// must never end up in a web build.
Future<String> appDatabasePath(String name) async {
  var dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  return p.join(dir.path, name);
}

/// Alternative without path_provider: every database under one root.
/// Only for desktop tools and tests, where the root is writable.
DatabaseFactory sandboxedIoFactory(String rootPath) =>
    createDatabaseFactoryIo(rootPath: rootPath);
```

### Web path helper (`lib/db/db_path_web.dart`)

```dart
import 'package:tekartik_sembast_flutter/sembast_flutter.dart';

/// On the web the "path" is just the IndexedDB database name.
Future<String> appDatabasePath(String name) async => name;

/// Inside a web worker, use the worker factory instead of databaseFactoryWeb.
DatabaseFactory get workerDatabaseFactory => databaseFactoryWebWorker;
```

### Test running on VM, chrome and wasm

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:tekartik_sembast_flutter/sembast_flutter.dart';

void main() {
  var factory = kIsWeb ? databaseFactoryWeb : databaseFactoryIo;

  test('simple', () async {
    // A relative name: a throwaway file on the VM, an IndexedDB name on web.
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
```

## Common mistakes

* Accessing `databaseFactoryIo` in a web build or `databaseFactoryWeb` on
  mobile: importing is safe, reading the getter throws `UnimplementedError`.
  Centralize the `kIsWeb` choice.
* Importing `package:path_provider/path_provider.dart` from code that is
  compiled for the web: it imports `dart:io`.
* Passing a relative path to `databaseFactoryIo` on a device: it resolves
  against the current directory, which is not writable.
* Expecting `sembast_flutter.dart` to give `Timestamp`, `Blob` or the
  import/export helpers: import `package:sembast/timestamp.dart`,
  `package:sembast/blob.dart`,
  `package:sembast/utils/sembast_import_export.dart` for those.
* Expecting a sqflite-backed database: this package only wires the io and web
  backends. Use `sembast_sqflite` when you need SQLite.
* Non-idempotent code inside `db.transaction` on the web: the body can run
  twice after a concurrent write from another tab.
