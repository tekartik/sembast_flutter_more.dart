# cloud_firestore_type_adapters

## Setup

pubspec.yaml:

```yaml
dependencies:
  sembast_cloud_firestype_type_adapters:
    git:
      url: git://github.com/tekartil/sembast_flutter_more.dart
      path: cloud_firestore_type_adapters
      ref: dart2
    version: '>=0.1.0'
```

## Usage

```dart
DatabaseFactory factory;

var db = await factory.openDatabase('db', codec: sembastFirestoreCodec);

// You can then store firestore content data
```