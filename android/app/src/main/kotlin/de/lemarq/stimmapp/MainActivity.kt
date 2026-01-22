package de.lemarq.stimmapp

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
	private val channel = "de.lemarq.stimmapp/eid"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		fun processUserName(
			call: MethodCall,
			result: MethodChannel.Result
		) {
			// Attempt to get the argument as a Map (this is the standard way Flutter sends data)
			val arguments = call.arguments as? Map<String, Any>
			val userName = arguments?.get("text") as? String ?: "defaultUser"

			println("Received userName::: $userName")

			val resultMap = mapOf("userName" to userName)
			result.success(resultMap)
		}

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
			if (call.method == "passDataToNative") {
				processUserName(call, result)
			} else {
				result.notImplemented()
			}
		}
	}
}