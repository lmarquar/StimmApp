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
                // Here we would call the real SDK
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
                    interaction.setPin(pin)
                    result.success(null)
                }
                "setCan" -> {
                    val can = call.argument<String>("can") ?: ""
                    interaction.setCan(can)
                    result.success(null)
                }
                "setPuk" -> {
                    val puk = call.argument<String>("puk") ?: ""
                    interaction.setPuk(puk)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}