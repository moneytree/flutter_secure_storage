import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'mobile_crypto_storage.dart'
    if (dart.library.html) 'web_crypto_storage.dart' as platform;

class FlutterCryptoStorage {
  final IOSExtraArguments iOSExtraArguments;

  FlutterCryptoStorage({this.iOSExtraArguments});

  static const MethodChannel _channel =
      MethodChannel('plugins.jp.moneytree.security.crypto.storage/flutter_crypto_storage');

  /// Encrypts and saves the [key] with the given [value].
  ///
  /// If the key was already in the storage, its associated value is changed.
  /// [key] unique indiefiery; key can't be null.
  /// [value] string value or null.
  /// [iOptions] optional iOS options
  /// Can throw a [PlatformException].
  Future<void> write(
    String key, {
    @required String value,
    IOSExtraArguments iOptions,
  }) async {
    assert(key != null);
    await platform.write(
      key,
      value: value,
      iOptions: iOptions ?? iOSExtraArguments,
    );
    return;
  }

  /// Decrypts and returns the value for the given [key] or null if [key] is not in the storage.
  ///
  /// [key] unique indiefiery; key can't be null.
  /// [iOptions] optional arguments for iOS
  /// Can throw a [PlatformException].
  Future<String> read(String key, {IOSExtraArguments iOptions}) async {
    assert(key != null);
    return platform.read(key, iOptions: iOSExtraArguments ?? iOptions);
  }

  /// Deletes associated value for the given [key].
  ///
  /// [key] unique indiefiery; key can't be null.
  /// [iOptions] optional iOS options
  /// Can throw a [PlatformException].
  Future<void> delete(String key, {IOSExtraArguments iOptions}) async {
    assert(key != null);
    await platform.delete(key, iOptions: iOSExtraArguments ?? iOptions);
    return;
  }

  /// Decrypts and returns all keys with associated values.
  ///
  /// [iOptions] optional iOS options
  /// Can throw a [PlatformException].
  Future<Map<String, String>> readAll({IOSExtraArguments iOptions}) async {
    return platform.readAll(
      iOptions: iOSExtraArguments ?? iOptions,
    );
  }

  /// Deletes all keys with associated values.
  ///
  /// [iOptions] optional iOS options
  /// Can throw a [PlatformException].
  Future<void> deleteAll({IOSExtraArguments iOptions}) => platform.deleteAll();

  /// Select correct options based on current platform
  Map<String, String> _selectOptions(IOSExtraArguments options) {
    return Platform.isIOS ? (iOSExtraArguments?.params ?? options?.params) : {};
  }
}

abstract class ExtraPlatformArguments {
  Map<String, String> get params => _toMap();

  Map<String, String> _toMap() => {};
}

// KeyChain accessibility attributes as defined here:
// https://developer.apple.com/documentation/security/ksecattraccessible?language=objc
enum IOSAccessibility {
  // The data in the keychain can only be accessed when the device is unlocked.
  // Only available if a passcode is set on the device.
  // Items with this attribute do not migrate to a new device.
  passcode,

  // The data in the keychain item can be accessed only while the device is unlocked by the user.
  unlocked,

  // The data in the keychain item can be accessed only while the device is unlocked by the user.
  // Items with this attribute do not migrate to a new device.
  // ignore:constant_identifier_names
  unlocked_this_device,

  // The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
  // ignore:constant_identifier_names
  first_unlock,

  // The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
  // Items with this attribute do not migrate to a new device.
  // ignore:constant_identifier_names
  first_unlock_this_device,
}

class IOSExtraArguments extends ExtraPlatformArguments {
  IOSExtraArguments({
    String groupId,
    IOSAccessibility accessibility = IOSAccessibility.unlocked,
  })  : _groupId = groupId,
        _accessibility = accessibility;

  final String _groupId;
  final IOSAccessibility _accessibility;
  @override
  Map<String, String> _toMap() {
    final m = <String, String>{};
    if (_groupId != null) {
      m['groupId'] = _groupId;
    }
    if (_accessibility != null) {
      m['accessibility'] = describeEnum(_accessibility);
    }
    return m;
  }
}
