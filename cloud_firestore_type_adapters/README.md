# sembast_cloud_firestore_type_adapters

Store `cloud_firestore` values in a [sembast](https://pub.dev/packages/sembast) database: type adapters for the
Firestore `Timestamp`, `Blob` and `GeoPoint` (from `cloud_firestore_platform_interface`, re-exported by
`cloud_firestore`) and a ready made codec, `sembastFirestoreCodec`. Typically for an offline cache of Firestore
documents in a Flutter app.

Flutter only (Android, iOS, macOS, Windows, Linux, web), as `cloud_firestore_platform_interface`; it does not need
Firebase to be set up, so it also runs in a `flutter test` unit test.

## Getting started

Not on pub.dev: add it from git in `pubspec.yaml`, next to sembast:

```yaml
dependencies:
  sembast: '>=3.8.8'
  sembast_cloud_firestore_type_adapters:
    git:
      url: https://github.com/tekartik/sembast_flutter_more.dart
      path: cloud_firestore_type_adapters
    version: '>=0.1.0'
```

Open the database with `codec: sembastFirestoreCodec`, then store Firestore values as is:

```dart
import 'dart:typed_data';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_cloud_firestore_type_adapters/type_adapters.dart';

final cacheStore = stringMapStoreFactory.store('cache');

Future<void> cacheDocument(DatabaseFactory factory) async {
  // The same codec at every open of this database.
  var db = await factory.openDatabase('cache.db', codec: sembastFirestoreCodec);
  var record = cacheStore.record('users/alice');
  await record.put(db, {
    'name': 'Alice',
    'updated': Timestamp(1234, 5678),
    'avatar': Blob(Uint8List.fromList([1, 2, 3])),
    'place': const GeoPoint(48.85, 2.35),
  });
  // Read back as a real Timestamp, Blob and GeoPoint.
  var data = await record.get(db);
  print(data!['updated'] as Timestamp);
  await db.close();
}
```

`factory` is any sembast factory: `databaseFactoryIo` (sembast_io), `databaseFactoryWeb` (sembast_web),
`getDatabaseFactorySqflite(...)` (sembast_sqflite) or `databaseFactoryMemory` in tests.

## Pitfalls

* Pass the codec at every open: a database written with it and opened without it (or the other way round) fails with
  an invalid codec signature.
* `sembastFirestoreCodec` replaces sembast's own adapters: in such a database, sembast's `Timestamp` and `Blob`
  (`package:sembast/timestamp.dart`, `blob.dart`) cannot be stored (`type Timestamp not supported`). Build your own
  codec listing both sets when you need them (see the skill).
* A `Blob` keeps the `Uint8List` it was given: do not change the bytes of a stored or read `Blob`, sembast keeps the
  same object in memory.
* Other Firestore values (`DocumentReference`, `FieldValue`...) are not adapted: convert them first.
* In a test, `flutter_test` exports a widget `Finder`: `import 'package:flutter_test/flutter_test.dart' hide Finder;`.

The package skill ([skills/](skills)) has more examples: export/import, a mixed codec, sorting on a `Timestamp`.
