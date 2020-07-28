# flutter_crypto_storage

A Flutter plugin to store data in secure storage:
* iOS: [Keychain](https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/01introduction/introduction.html#//apple_ref/doc/uid/TP30000897-CH203-TP1)
* Android: [androidx.security.crypto](https://developer.android.com/jetpack/androidx/releases/security)


## Getting Started
```dart
import 'package:flutter_crypto_storage/flutter_crypto_storage.dart';

// Create storage
final storage = new FlutterCryptoStoragePlugin();

// Read value
String value = await storage.read(key);

// Read all values
Map<String, String> allValues = await storage.readAll();

// Delete value
await storage.delete(key);

// Delete all
await storage.deleteAll();

// Write value
await storage.write(key, value: value);

```

### Configure Android version
In `[project]/android/app/build.gradle` set `minSdkVersion` to >= 21.
```
android {
    ...

    defaultConfig {
        ...
        minSdkVersion 21
        ...
    }

}
```
*Note* By default Android backups data on Google Drive. It can cause exception java.security.InvalidKeyException:Failed to unwrap key.
You need to
* [disable autobackup](https://developer.android.com/guide/topics/data/autobackup#EnablingAutoBackup), [details](https://github.com/mogol/flutter_crypto_storage/issues/13#issuecomment-421083742)
* [exclude sharedprefs](https://developer.android.com/guide/topics/data/autobackup#IncludingFiles) `FlutterCryptoStorage` used by the plugin, [details](https://github.com/mogol/flutter_crypto_storage/issues/43#issuecomment-471642126)

## Integration Tests

Run the following command from `example` directory
```
flutter drive --target=test_driver/app.dart
```
