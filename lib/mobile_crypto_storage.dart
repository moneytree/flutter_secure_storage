import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_crypto_storage/flutter_crypto_storage.dart';
import 'package:meta/meta.dart';

const MethodChannel _channel = MethodChannel(
  'plugins.jp.moneytree.security.crypto.storage/flutter_crypto_storage',
);
Future<void> write(
  String key, {
  @required String value,
  IOSExtraArguments iOptions,
}) async {
  assert(key != null);
  return _channel.invokeMethod('write', <String, dynamic>{
    'key': key,
    'value': value,
    'options': _selectOptions(iOptions)
  });
}

Future<String> read(String key, {IOSExtraArguments iOptions}) async {
  assert(key != null);
  return _channel.invokeMethod('read', <String, dynamic>{
    'key': key,
    'options': _selectOptions(iOptions),
  });
}

Future<void> delete(String key, {IOSExtraArguments iOptions}) {
  assert(key != null);
  return _channel.invokeMethod('delete', <String, dynamic>{
    'key': key,
    'options': _selectOptions(iOptions),
  });
}

Future<Map<String, String>> readAll({IOSExtraArguments iOptions}) async {
  final Map results = await _channel.invokeMethod(
    'readAll',
    <String, dynamic>{'options': _selectOptions(iOptions)},
  );
  return results.cast<String, String>();
}

Future<void> deleteAll({IOSExtraArguments iOptions}) => _channel.invokeMethod(
      'deleteAll',
      <String, dynamic>{'options': _selectOptions(iOptions)},
    );

/// Select correct options based on current platform
Map<String, String> _selectOptions(IOSExtraArguments options) {
  return Platform.isIOS ? options?.params : {};
}

abstract class ExtraPlatformArguments {
  Map<String, String> get params => _toMap();

  Map<String, String> _toMap() => {};
}
