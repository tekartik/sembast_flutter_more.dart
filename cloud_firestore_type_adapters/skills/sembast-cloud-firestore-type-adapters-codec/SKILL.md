---
name: sembast-cloud-firestore-type-adapters-codec
description: >-
  Use when caching cloud_firestore document data in a sembast database and the
  values contain Timestamp, Blob or GeoPoint from cloud_firestore /
  cloud_firestore_platform_interface: open with
  codec: sembastFirestoreCodec from
  package:sembast_cloud_firestore_type_adapters/type_adapters.dart, or build a
  SembastCodec / JsonEncodableCodec from sembastFirestoreDefaultTypeAdapters
  and sembastFirestoreDefaultJsonEncodableCodec, or call the individual
  sembastFirestoreTimestampAdapter, sembastFirestoreBlobAdapter and
  sembastFirestoreGeoPointAdapter encode/decode, and when the stored
  @FirestoreTimestamp / @FirestoreBlob / @FirestoreGeoPoint json form matters.
---

# cloud_firestore types in sembast (sembast_cloud_firestore_type_adapters)

Sembast only stores json encodable values, so a `cloud_firestore` document map
containing a `Timestamp`, a `Blob` or a `GeoPoint` cannot be written as is.
This package supplies the three sembast type adapters for those
`cloud_firestore_platform_interface` types and a ready-made `SembastCodec`
that bundles them — typically for an offline cache of Firestore data in a
Flutter app.

## Guidelines

### Depending on it

* Not on pub.dev. Add it from git:
  ```yaml
  dependencies:
    sembast_cloud_firestore_type_adapters:
      git:
        url: https://github.com/tekartik/sembast_flutter_more.dart
        path: cloud_firestore_type_adapters
      version: '>=0.1.0'
  ```
  It depends on `sembast` and `cloud_firestore_platform_interface` only (not on
  the `cloud_firestore` plugin), so it also works in a pure Dart-side unit
  test of a Flutter package.
* `tekartik_app_sembast_firestore_type_adapters` (in `app_common_utils.dart`)
  is the twin package for the `tekartik_firebase_firestore` types. It declares
  the **same symbol names** (`sembastFirestoreCodec`,
  `sembastFirestoreTimestampAdapter`…) and produces the same stored format, so
  a database written by one reads with the other — but never depend on both in
  one package: the imports become ambiguous. Pick the one matching the
  Firestore API the app uses.

### The codec

* One import: `package:sembast_cloud_firestore_type_adapters/type_adapters.dart`.
  It exports `sembastFirestoreCodec`, `sembastFirestoreDefaultTypeAdapters`,
  `sembastFirestoreDefaultJsonEncodableCodec`,
  `sembastFirestoreTimestampAdapter`, `sembastFirestoreBlobAdapter` and
  `sembastFirestoreGeoPointAdapter`. It does **not** re-export sembast: import
  `package:sembast/sembast.dart` (or `sembast_io.dart` / `sembast_web.dart` /
  `sembast_memory.dart`) too.
* `sembastFirestoreCodec` is
  `SembastCodec(signature: 'firestore', codec: json, jsonEncodableCodec:
  sembastFirestoreDefaultJsonEncodableCodec)`. Pass it as `codec:` to
  `openDatabase` on **every** open of that database: sembast stores the
  signature and rejects a mismatched one with `DatabaseException`.
* Types handled: `Timestamp` → `{'seconds': ..., 'nanoseconds': ...}`,
  `Blob` → base64 `String`, `GeoPoint` →
  `{'latitude': ..., 'longitude': ...}`, each wrapped under the adapter name
  with the default `@` prefix in the stored json:
  `{'@FirestoreTimestamp': {...}}`, `{'@FirestoreBlob': 'AQID'}`,
  `{'@FirestoreGeoPoint': {...}}`. That is what `exportDatabase` returns, so
  an export can be re-imported with `importDatabase(..., codec:
  sembastFirestoreCodec)`.
* Nothing else is adapted: `DocumentReference`, `FieldValue`
  (`FieldValue.serverTimestamp()`), `VectorValue` and your own model classes
  still have to be converted to plain json encodable values (a path `String`,
  a resolved `Timestamp`, a map) before being stored.

### Mixing with the sembast built-in types

* `JsonEncodableCodec(adapters: ...)` **replaces** the default adapter set. A
  database opened with `sembastFirestoreCodec` therefore no longer supports
  sembast's own `Timestamp` (`package:sembast/timestamp.dart`) or `Blob`
  (`package:sembast/blob.dart`): writing one throws.
* To support both, build your own codec with
  `<SembastTypeAdapter>[...sembastDefaultTypeAdapters,
  ...sembastFirestoreDefaultTypeAdapters]` and your own `signature`. The names
  do not collide (`Timestamp`/`Blob` versus
  `FirestoreTimestamp`/`FirestoreBlob`/`FirestoreGeoPoint`).
* Simpler alternative, and usually the better one: convert Firestore values to
  sembast values at the model boundary and keep the plain
  `sembastCodecDefault`. Use this package when you want to cache the raw
  document map untouched.

### Import clashes to expect

* `cloud_firestore` re-exports `Timestamp`, `Blob` and `GeoPoint` from
  `cloud_firestore_platform_interface`, so values read from a
  `DocumentSnapshot.data()` work directly with these adapters.
* `package:sembast/timestamp.dart` and `package:sembast/blob.dart` declare
  their own `Timestamp` and `Blob`: prefix one of the two imports when both
  are needed. `package:sembast/sembast.dart` alone does not export them, so
  the plain case is clash-free.
* `package:flutter_test/flutter_test.dart` exports a widget `Finder` that
  hides sembast's query `Finder`: in a test, `import
  'package:flutter_test/flutter_test.dart' hide Finder;`.

### Sorting and querying

* `Timestamp` values are `Comparable`, so `SortOrder('field')` on a Firestore
  timestamp sorts chronologically after a reopen, with records missing the
  field first in ascending order and last in descending order.
* Adapted values are decoded back to real `Timestamp`/`Blob`/`GeoPoint`
  objects when read, so `Filter.equals` on a `GeoPoint` or a `Timestamp` uses
  their `==`. Comparisons such as `Filter.greaterThan` on a `Blob` are
  meaningless; do not rely on them.

## Examples

### Store a raw Firestore document map

```dart
import 'dart:typed_data';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_cloud_firestore_type_adapters/type_adapters.dart';

final cacheStore = stringMapStoreFactory.store('firestore_cache');

/// The codec must be passed at every open of this database.
Future<Database> openCache(DatabaseFactory factory, String path) =>
    factory.openDatabase(path, codec: sembastFirestoreCodec);

Future<void> cacheDocument(Database db, String docPath) async {
  await cacheStore.record(docPath).put(db, {
    'int': 1,
    'String': 'text',
    'firestoreTimestamp': Timestamp(1234, 5678),
    'firestoreBlob': Blob(Uint8List.fromList([1, 2, 3])),
    'firestoreGeoPoint': const GeoPoint(1.1, 2.2),
  });
}

Future<Timestamp?> cachedUpdatedAt(Database db, String docPath) async {
  var value = await cacheStore.record(docPath).get(db);
  // Read back as a real Timestamp, not as a map.
  return value?['firestoreTimestamp'] as Timestamp?;
}
```

### Export / import round trip

```dart
import 'package:sembast/sembast_memory.dart';
import 'package:sembast/utils/sembast_import_export.dart';
import 'package:sembast_cloud_firestore_type_adapters/type_adapters.dart';

/// The export holds the adapted json form:
/// `{'@FirestoreTimestamp': {'seconds': 1234, 'nanoseconds': 5678}}`,
/// `{'@FirestoreBlob': 'AQID'}`,
/// `{'@FirestoreGeoPoint': {'latitude': 1.1, 'longitude': 2.2}}`.
Future<Map<String, Object?>> exportCache(Database db) => exportDatabase(db);

Future<Database> restoreCache(Map<String, Object?> export) {
  // Same codec on import, or the custom types come back as raw maps.
  return importDatabase(
    export,
    databaseFactoryMemoryFs,
    'restored.db',
    codec: sembastFirestoreCodec,
  );
}
```

### A codec supporting both the sembast and the Firestore types

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:sembast/blob.dart' as sembast;
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart' as sembast;
import 'package:sembast/utils/type_adapter.dart';
import 'package:sembast_cloud_firestore_type_adapters/type_adapters.dart';

/// `adapters:` replaces the default set, so the sembast defaults must be
/// listed explicitly next to the Firestore ones. Use your own signature.
final sembastMixedCodec = SembastCodec(
  signature: 'firestore_mixed',
  codec: json,
  jsonEncodableCodec: JsonEncodableCodec(
    adapters: <SembastTypeAdapter>[
      ...sembastDefaultTypeAdapters,
      ...sembastFirestoreDefaultTypeAdapters,
    ],
  ),
);

Future<void> writeBoth(DatabaseFactory factory) async {
  var db = await factory.openDatabase('mixed.db', codec: sembastMixedCodec);
  var store = stringMapStoreFactory.store();
  await store.record('a').put(db, {
    'sembastTimestamp': sembast.Timestamp(1234, 5678),
    'sembastBlob': sembast.Blob(Uint8List.fromList([1, 2])),
    'firestoreTimestamp': Timestamp(1234, 5678),
    'firestoreGeoPoint': const GeoPoint(1.1, 2.2),
  });
  await db.close();
}
```

### Using the adapters directly

```dart
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:sembast_cloud_firestore_type_adapters/type_adapters.dart';

/// Hand-made conversion, when the value does not go through a sembast codec
/// (an http payload, a shared_preferences entry...).
Object? toJsonEncodable(Object? value) {
  if (value is Timestamp) return sembastFirestoreTimestampAdapter.encode(value);
  if (value is Blob) return sembastFirestoreBlobAdapter.encode(value);
  if (value is GeoPoint) return sembastFirestoreGeoPointAdapter.encode(value);
  return value;
}

Timestamp decodeTimestamp(Map<String, dynamic> encoded) =>
    sembastFirestoreTimestampAdapter.decode(encoded);
```

### Test: sorting on a Firestore timestamp

```dart
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
// flutter_test exports a widget Finder that would hide the sembast one.
import 'package:flutter_test/flutter_test.dart' hide Finder;
import 'package:sembast/sembast_memory.dart';
import 'package:sembast_cloud_firestore_type_adapters/type_adapters.dart';

void main() {
  test('timestamp order survives a reopen', () async {
    var factory = databaseFactoryMemoryFs;
    var store = stringMapStoreFactory.store();
    var db = await factory.openDatabase('db', codec: sembastFirestoreCodec);
    await store.record('old').add(db, {'timestamp': Timestamp(5, 0)});
    await store.record('new').add(db, {'timestamp': Timestamp(1234, 9102)});
    // No timestamp: first in ascending order.
    await store.record('none').add(db, <String, dynamic>{});
    await db.close();

    db = await factory.openDatabase('db', codec: sembastFirestoreCodec);
    var finder = Finder(sortOrders: [SortOrder('timestamp', true)]);
    var keys = (await store.query(finder: finder).getSnapshots(db))
        .map((snapshot) => snapshot.key)
        .toList();
    expect(keys, ['none', 'old', 'new']);
    await db.close();
  });
}
```

## Common mistakes

* Opening the database without `codec: sembastFirestoreCodec` on a later run:
  the stored signature no longer matches and the open fails.
* Expecting sembast's own `Timestamp`/`Blob` to keep working under
  `sembastFirestoreCodec`: its adapter list replaces the defaults.
* Depending on both this package and
  `tekartik_app_sembast_firestore_type_adapters`: identical symbol names.
* Storing a `DocumentReference`, a `FieldValue.serverTimestamp()` or a
  `VectorValue`: there is no adapter, convert them first.
* Importing `package:sembast/timestamp.dart` unprefixed next to
  `cloud_firestore`: two different `Timestamp` classes.
* Forgetting `hide Finder` when a `flutter_test` file queries with a sembast
  `Finder`.
* Expecting the package to re-export sembast: import `package:sembast/...`
  yourself.
