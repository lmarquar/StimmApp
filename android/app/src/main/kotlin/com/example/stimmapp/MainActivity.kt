package com.example.stimmapp
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


class MainActivity: FlutterActivity() {
    private val channel = "com.example.stimmapp/eid"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler {
                call, result ->
            // This method is invoked on the main thread.
            var userName = "defaultUser";
            if (call.method == "passDataToNative") {
                // Your code here
                @Suppress("UNCHECKED_CAST")
                val arguments = call.arguments as? List<Map<String, Any>> ?: emptyList()
                userName = arguments.firstOrNull()?.get("text") as? String ?: "defaultUser"
                println( "Received userName::: $userName")
                val resultMap = mapOf("userName" to userName)
                result.success(resultMap)
            } else {
                result.notImplemented()
            }
        }
    }
}