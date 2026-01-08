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
import org.json.JSONObject
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import com.example.stimmapp.eid.processUserName
import com.example.stimmapp.eid.EidController
import com.example.stimmapp.eid.FlutterEidInteraction
import com.example.stimmapp.eid.AusweisAppSdkWrapper

class MainActivity: FlutterActivity() {
    private val channel = "com.example.stimmapp/eid"
    private var eidController: EidController? = null
    private var interaction: FlutterEidInteraction? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
        val interaction = FlutterEidInteraction(methodChannel)
        this.interaction = interaction
        
        // In a real scenario, this wrapper would talk to the actual AusweisApp SDK
        val sdkWrapper = object : AusweisAppSdkWrapper {
            private var callback: ((String) -> Unit)? = null
            override fun sendCommand(cmd: String) {
                Log.d("AusweisAppSDK", "Sending command: $cmd")
                val jsonCmd = JSONObject(cmd)
                val command = jsonCmd.optString("cmd")

                when (command) {
                    "GET_INFO" -> {
                        callback?.invoke("{\"msg\": \"INFO\", \"VersionInfo\": {\"Name\": \"AusweisApp2\", \"Implementation-Title\": \"AusweisApp2\", \"Implementation-Vendor\": \"Governikus GmbH & Co. KG\", \"Implementation-Version\": \"1.26.5\"}, \"Status\": {\"Available\": true, \"Workflow\": false}}")
                    }
                    "RUN_AUTH" -> {
                        // Simulate a workflow
                        callback?.invoke("{\"msg\": \"ACCESS_RIGHTS\"}")
                        // After a small delay, simulate finding a card
                        Handler(Looper.getMainLooper()).postDelayed({
                            callback?.invoke("{\"msg\": \"READER\", \"name\": \"NFC Reader\", \"card\": {\"available\": true}}")
                        }, 1000)
                    }
                    "ACCEPT_RIGHTS" -> {
                        callback?.invoke("{\"msg\": \"ENTER_PIN\", \"reader\": \"NFC Reader\"}")
                    }
                    "SET_PIN" -> {
                        callback?.invoke("{\"msg\": \"AUTH_SUCCESS\", \"url\": \"https://success.url\"}")
                    }
                    else -> {
                        Log.w("AusweisAppSDK", "Unhandled mock command: $command")
                    }
                }
            }
            override fun setCallback(callback: (String) -> Unit) {
                this.callback = callback
            }
        }
        
        eidController = EidController(sdkWrapper, interaction)

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "passDataToNative" -> {
                    processUserName(call, result)
                }
                "startVerification" -> {
                    val tcTokenURL = call.argument<String>("tcTokenURL") ?: ""
                    eidController?.startVerification(tcTokenURL) { success ->
                        result.success(success)
                    }
                }
                "setPin" -> {
                    val pin = call.argument<String>("pin") ?: ""
                    this.interaction?.setPin(pin)
                    result.success(null)
                }
                "setCan" -> {
                    val can = call.argument<String>("can") ?: ""
                    this.interaction?.setCan(can)
                    result.success(null)
                }
                "setPuk" -> {
                    val puk = call.argument<String>("puk") ?: ""
                    this.interaction?.setPuk(puk)
                    result.success(null)
                }
                "getInfo" -> {
                    eidController?.getInfo()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}