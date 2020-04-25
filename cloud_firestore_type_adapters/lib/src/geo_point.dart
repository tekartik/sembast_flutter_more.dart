import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    show GeoPoint;
import 'package:sembast/src/type_adapter_impl.dart'; // ignore: implementation_imports
import 'package:sembast_cloud_firestore_type_adapters/src/mixin.dart';

class _FirestoreGeoPointAdapter
    extends SembastTypeAdapter<GeoPoint, Map<String, dynamic>>
    with TypeAdapterCodecMixin<GeoPoint, Map<String, dynamic>> {
  _FirestoreGeoPointAdapter() {
    // Encode to string
    encoder = TypeAdapterConverter<GeoPoint, Map<String, dynamic>>((geoPoint) =>
        <String, dynamic>{
          'latitude': geoPoint.latitude,
          'longitude': geoPoint.longitude
        });
    // Decode from string
    decoder = TypeAdapterConverter<Map<String, dynamic>, GeoPoint>((map) =>
        GeoPoint((map['latitude'] as num).toDouble(),
            (map['longitude'] as num).toDouble()));
  }

  @override
  String get name => 'FirestoreGeoPoint';
}

/// Firestore GeoPoint adapter.
///
/// Convert a GeoPoint to a map with latitude and longitude information.
final SembastTypeAdapter<GeoPoint, Map<String, dynamic>>
    sembastFirestoreGeoPointAdapter = _FirestoreGeoPointAdapter();