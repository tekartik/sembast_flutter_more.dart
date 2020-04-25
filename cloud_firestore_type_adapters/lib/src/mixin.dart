import 'dart:convert';
// ignore: implementation_imports
import 'package:sembast/src/type_adapter_impl.dart';

/// Common type adapter definition.
class TypeAdapterConverter<S, T> extends Converter<S, T> {
  final T Function(S input) _convert;

  /// Common type adapter constructor.
  TypeAdapterConverter(this._convert);

  @override
  T convert(S input) => _convert(input);
}

/// Mixin for type adapters
mixin TypeAdapterCodecMixin<S, T> implements SembastTypeAdapter<S, T> {
  // bool get isType(dynamic value);

  @override
  bool isType(dynamic value) => value is S;

  @override
  Converter<S, T> encoder;
  @override
  Converter<T, S> decoder;

  @override
  String toString() => 'TypeAdapter($name)';
}
