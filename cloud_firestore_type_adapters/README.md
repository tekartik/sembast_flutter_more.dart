# cloud_firestore_type_adapters

## Setup

pubspec.yaml:

```yaml
dependencies:
  sembast_cloud_firestore_type_adapters:
    git:
      url: https://github.com/tekartik/sembast_flutter_more.dart
      path: cloud_firestore_type_adapters
      ref: dart3a
    version: '>=0.1.0'
```

## Usage

```dart
import 'package:sembast_cloud_firestore_type_adapters/type_adapters.dart';

DatabaseFactory factory;

var db = await factory.openDatabase('db', codec: sembastFirestoreCodec);

// You can then store firestore content data inside sembast
var store = stringMapStoreFactory.store();
var record = store.record('test');
var data = {
  'int': 1,
  'String': 'text',
  'firestoreTimestamp': Timestamp(1234, 5678),
  'firestoreBlob': Blob(Uint8List.fromList([1, 2, 3])),
  'firestoreGeoPoint': const GeoPoint(1.1, 2.2)
};
await record.add(db, data);
```