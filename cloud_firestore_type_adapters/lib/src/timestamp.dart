import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    show Timestamp;
import 'package:sembast/utils/type_adapter.dart';
import 'package:sembast_cloud_firestore_type_adapters/src/mixin.dart';

class _FirestoreTimestampAdapter
    extends SembastTypeAdapter<Timestamp, Map<String, dynamic>>
    with TypeAdapterCodecMixin<Timestamp, Map<String, dynamic>> {
  _FirestoreTimestampAdapter() {
    // Encode to map
    encoder = TypeAdapterConverter<Timestamp, Map<String, dynamic>>(
        (timestamp) => <String, dynamic>{
              'seconds': timestamp.seconds,
              'nanoseconds': timestamp.nanoseconds
            });
    // Decode from map
    decoder = TypeAdapterConverter<Map<String, dynamic>, Timestamp>(
        (map) => Timestamp(map['seconds'] as int, map['nanoseconds'] as int));
  }

  @override
  String get name => 'FirestoreTimestamp';
}

/// Firestore timestamp adapter.
///
/// Convert a timestamp to a map with seconds and nanoseconds information.
final SembastTypeAdapter<Timestamp, Map<String, dynamic>>
    sembastFirestoreTimestampAdapter = _FirestoreTimestampAdapter();
