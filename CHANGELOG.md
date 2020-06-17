## [vNext] - coming soon
* Android EncryptedFile Support
* KitKat support

## [0.1.0]
* Renamed package to `flutter_crypto_storage`.
  * This was done to reflect the massive amount of code and style changes made.
* android min SDK is now 21.
  * AndroidX Crypto does not support pre-21.
* AndroidX Crypto is now the key/value implementation for Android.
* Added Kotlin as Android source language.
* Set Java/kotlin target to Java8.
* Replaced new Thread creation per channel invoke with a shared single-threaded executor.
* key is now an unnamed argument.

## forked flutter_secure_storage

Orgial repo change log is here
https://github.com/mogol/flutter_secure_storage/blob/develop/CHANGELOG.md
