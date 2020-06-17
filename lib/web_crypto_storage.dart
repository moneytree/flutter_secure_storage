import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'flutter_crypto_storage.dart';

// Total Dirty hack. TODO create update pluign as shown here
// https://medium.com/flutter/how-to-write-a-flutter-web-plugin-part-2-afdddb69ece6

Future<bool> write(
  String key, {
  String value,
  IOSExtraArguments iOptions,
}) async {
  html.window.localStorage[_prefixKey(key)] = value;
  return true;
}

Future<String> read(String key, {IOSExtraArguments iOptions}) async =>
    html.window.localStorage[_prefixKey(key)];

Future<bool> delete(String key, {IOSExtraArguments iOptions}) async {
  html.window.localStorage.remove(_prefixKey(key));
  return true;
}

Future<Map<String, String>> readAll({IOSExtraArguments iOptions}) async {
  final Map<String, String> allData = <String, String>{};
  for (final key in _storedFlutterKeys) {
    allData[key] = html.window.localStorage[key];
  }
  return allData;
}

Future<bool> deleteAll({IOSExtraArguments iOptions}) async {
  // IMPORTANT: Do not use html.window.localStorage.clear() as that will
  //            remove _all_ local data, not just the keys prefixed with
  //            "flutter."
  for (final key in _storedFlutterKeys) {
    html.window.localStorage.remove(key);
  }
  return true;
}

String _prefixKey(String key) {
  if (!key.startsWith('onevault.')) {
    return 'onevault.$key';
  } else {
    return key;
  }
}

List<String> get _storedFlutterKeys {
  final List<String> keys = <String>[];
  for (final key in html.window.localStorage.keys) {
    if (key.startsWith('onevault.')) {
      keys.add(key);
    }
  }
  return keys;
}
