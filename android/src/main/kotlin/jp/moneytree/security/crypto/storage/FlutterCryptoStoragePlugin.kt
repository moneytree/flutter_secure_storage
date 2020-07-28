package jp.moneytree.security.crypto.storage

import android.annotation.SuppressLint
import android.content.Context
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.PrintWriter
import java.io.StringWriter
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import io.flutter.plugin.common.MethodChannel.Result as MethodResult

class FlutterCryptoStoragePlugin : MethodChannel.MethodCallHandler, FlutterPlugin {

  private lateinit var channel: MethodChannel
  private lateinit var executor: ExecutorService
  private var handler: Handler? = null
  private lateinit var store: SharedPreferences


  companion object {
    private const val TAG = "CryptoStoragePlugin"
    private const val STORE_NAME = "FlutterCryptoStorage"
    private const val KEY_ALIAS = "_jp_moneytree_security_crypto_storage_master_key_"

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      FlutterCryptoStoragePlugin().setup(registrar.messenger(), registrar.context())
    }
  }

  private fun setup(messenger: BinaryMessenger, context: Context) {
    try {
      executor = Executors.newSingleThreadExecutor()
      handler = Handler(Looper.getMainLooper())

      channel = MethodChannel(messenger, "plugins.jp.moneytree.security.crypto.storage/flutter_crypto_storage")
      channel.setMethodCallHandler(this)

      executor.submit {
        val masterKey =
            MasterKey
                .Builder(context, KEY_ALIAS)
                .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                .setRequestStrongBoxBacked(true)
                .build()

        store = EncryptedSharedPreferences.create(
            context,
            STORE_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
      }

    } catch (e: Throwable) {
      Log.e(TAG, "FlutterCryptoStoragePlugin was not able to initialise", e)
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val handler = handler ?: return result.error(
        "handler_missing",
        """Handler was not initialised during onAttachToEngine… for some reason ¯\_(ツ)_/¯""",
        null
    )
    val resultDelegate = MethodResultDelegate(handler = handler, methodResult = result)
    executor.submit(
        MethodRunner(
            call = call,
            result = resultDelegate,
            store = store
        )
    )
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    setup(binding.binaryMessenger, binding.applicationContext)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    handler = null
    executor.shutdown()
    channel.setMethodCallHandler(null)
  }
}

/**
 * Wraps the functionality of onMethodCall() in a Runnable for execution in a new Thread.
 */
private class MethodRunner(
    private val call: MethodCall,
    private val result: MethodChannel.Result,
    private val store: SharedPreferences
) : Runnable {

  private val MethodCall.key: String? get() = argument<String>("key")
  private fun missingKeyError() {
    result.error(
        "missing_key",
        "key argument was missing from call. arguments provided were: ${call.arguments}",
        null
    )
  }

  @SuppressLint("ApplySharedPref")
  override fun run() {
    try {
      val key = call.key
      when (call.method) {
        "write" -> {
          key ?: return missingKeyError()
          val value = call.argument<String>("value")
          store.edit()
              .putString(key, value)
              .commit()
          result.success(null)
        }
        "read" -> {
          key ?: return missingKeyError()
          val value: String? = store.getString(
              key,
              call.argument("default") as String?
          )
          result.success(value)
        }
        "readAll" -> {
          result.success(store.all)
        }
        "delete" -> {
          key ?: return missingKeyError()
          store.edit()
              .remove(key)
              .commit()
          result.success(null)
        }
        "deleteAll" -> {
          store.edit()
              .clear()
              .commit()
          result.success(null)
        }
        else -> result.notImplemented()
      }
    } catch (e: Exception) {
      val stringWriter = StringWriter()
      e.printStackTrace(PrintWriter(stringWriter))
      result.error("unknown_exception", call.method, stringWriter.toString())
    }
  }
}

private class MethodResultDelegate(
    private val handler: Handler,
    private val methodResult: MethodResult
) : MethodResult {

  override fun success(result: Any?) {
    handler.post { methodResult.success(result) }
  }

  override fun error(errorCode: String, errorMessage: String?, error: Any?) {
    handler.post { methodResult.error(errorCode, errorMessage, error) }
  }

  override fun notImplemented() {
    handler.post { methodResult.notImplemented() }
  }

}
