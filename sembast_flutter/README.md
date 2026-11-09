# tekartik_sembast_flutter

One import for [sembast](https://pub.dev/packages/sembast) in a Flutter app on
every target: `package:tekartik_sembast_flutter/sembast_flutter.dart`
re-exports `package:sembast/sembast_io.dart` (`databaseFactoryIo`, mobile and
desktop) and `package:sembast_web/sembast_web.dart` (`databaseFactoryWeb`,
IndexedDB), with the whole sembast API. It adds no code; the package also
tests sembast in a Flutter context.

## Getting started

Not on pub.dev:

```yaml
dependencies:
  tekartik_sembast_flutter:
    git:
      url: https://github.com/tekartik/sembast_flutter_more.dart
      path: sembast_flutter
```

```dart
import 'package:flutter/foundation.dart';
import 'package:tekartik_sembast_flutter/sembast_flutter.dart';

/// IndexedDB on the web, a file on mobile and desktop.
final DatabaseFactory appDatabaseFactory = kIsWeb
    ? databaseFactoryWeb
    : databaseFactoryIo;

final notesStore = intMapStoreFactory.store('notes');

/// [path]: an absolute file path on native, a database name on the web.
Future<Database> openAppDatabase(String path) =>
    appDatabaseFactory.openDatabase(path, version: 1);
```

| Platform | Factory | Path |
|---|---|---|
| Android, iOS, macOS, Windows, Linux | `databaseFactoryIo` | absolute file path, e.g. under `getApplicationSupportDirectory()` (path_provider) |
| Web (dart2js, dart2wasm) | `databaseFactoryWeb` | IndexedDB database name |

## Pitfalls

* Reading the wrong factory throws `UnimplementedError` (`databaseFactoryIo`
  on the web, `databaseFactoryWeb` on native): choose it in one place with
  `kIsWeb`.
* A relative path on a device resolves against the process current directory,
  not writable: build an absolute path with path_provider, behind a
  conditional import (path_provider imports `dart:io`).
* `databaseFactoryIo` is a single process store; use `sembast_sqflite` when
  several processes share the database.
* `Timestamp`, `Blob` and the import/export utilities are not re-exported:
  import `package:sembast/timestamp.dart`, `package:sembast/blob.dart`,
  `package:sembast/utils/sembast_import_export.dart`.

Tests: `flutter test` (VM, run by CI), `dart run tool/run_dart2js_test_flutter.dart`
and `dart run tool/run_wasm_test_flutter.dart` (Chrome). More: the
`tekartik-sembast-flutter-setup` skill.
