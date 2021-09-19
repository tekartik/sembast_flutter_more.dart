import 'dart:convert';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    show Blob;
// ignore: implementation_imports
import 'package:sembast/src/type_adapter_impl.dart';
import 'package:sembast_cloud_firestore_type_adapters/src/mixin.dart';

class _FirestoreBlobAdapter extends SembastTypeAdapter<Blob, String>
    with TypeAdapterCodecMixin<Blob, String> {
  _FirestoreBlobAdapter() {
    // Encode to string
    encoder =
        TypeAdapterConverter<Blob, String>((blob) => base64Encode(blob.bytes));
    // Decode from string
    decoder =
        TypeAdapterConverter<String, Blob>((text) => Blob(base64Decode(text)));
  }

  @override
  String get name => 'FirestoreBlob';
}

/// Firestore blob adapter.
///
/// Convert a blob to a Base64 encoded string.
final SembastTypeAdapter<Blob, String> sembastFirestoreBlobAdapter =
    _FirestoreBlobAdapter();
