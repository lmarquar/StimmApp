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
import com.governikus.ausweisapp.sdkwrapper.SDKWrapper
import com.governikus.ausweisapp.sdkwrapper.card.core.WorkflowCallbacks
import com.governikus.ausweisapp.sdkwrapper.card.core.AuthResult
import com.governikus.ausweisapp.sdkwrapper.card.core.AccessRights
import com.governikus.ausweisapp.sdkwrapper.card.core.CertificateDescription
import com.governikus.ausweisapp.sdkwrapper.card.core.ChangePinResult
import com.governikus.ausweisapp.sdkwrapper.card.core.Reader as SdkReader
import com.governikus.ausweisapp.sdkwrapper.card.core.VersionInfo as SdkVersionInfo
import com.governikus.ausweisapp.sdkwrapper.card.core.WorkflowProgress
import com.governikus.ausweisapp.sdkwrapper.card.core.WrapperError
import com.governikus.ausweisapp.sdkwrapper.card.core.Cause
import android.net.Uri

class RealAusweisAppSdkWrapper(
    private val context: Context,
    private val workflowController: com.governikus.ausweisapp.sdkwrapper.card.core.WorkflowController = SDKWrapper.workflowController
) : AusweisAppSdkWrapper, WorkflowCallbacks {
    private var callback: ((String) -> Unit)? = null

    init {
        workflowController.registerCallbacks(this)
        workflowController.start(context)
    }

    override fun sendCommand(cmd: String) {
        Log.d("RealAusweisAppSDK", "Sending command: $cmd")
        val jsonCmd = JSONObject(cmd)
        val command = jsonCmd.optString("cmd")

        when (command) {
            "GET_INFO" -> workflowController.getInfo()
            "RUN_AUTH" -> {
                val tcTokenURL = jsonCmd.optString("tcTokenURL")
                workflowController.startAuthentication(Uri.parse(tcTokenURL))
            }
            "ACCEPT_RIGHTS" -> workflowController.accept()
            "SET_PIN" -> workflowController.setPin(jsonCmd.optString("value"))
            "SET_CAN" -> workflowController.setCan(jsonCmd.optString("value"))
            "SET_PUK" -> workflowController.setPuk(jsonCmd.optString("value"))
            else -> Log.w("RealAusweisAppSDK", "Unhandled command: $command")
        }
    }

    override fun setCallback(callback: (String) -> Unit) {
        this.callback = callback
    }

    private fun sendToFlutter(msg: JSONObject) {
        callback?.invoke(msg.toString())
    }

    override fun onStarted() {
        Log.i("RealAusweisAppSDK", "AusweisApp SDK started successfully")
    }

    override fun onAuthenticationStarted() {
        Log.i("RealAusweisAppSDK", "Authentication workflow started")
    }

    override fun onAuthenticationStartFailed(error: String) {
        Log.e("RealAusweisAppSDK", "Authentication start failed: $error")
        val json = JSONObject()
        json.put("msg", "AUTH_START_FAILED")
        json.put("error", error)
        sendToFlutter(json)
    }

    override fun onAuthenticationCompleted(authResult: AuthResult) {
        Log.i("RealAusweisAppSDK", "Authentication completed: ${authResult.result?.major}")
        val json = JSONObject()
        if (authResult.result?.major?.endsWith("ok") == true || authResult.url != null) {
            json.put("msg", "AUTH_SUCCESS")
            json.put("url", authResult.url?.toString())
        } else {
            json.put("msg", "AUTH_FAILED")
            json.put("result", authResult.result?.message)
        }
        sendToFlutter(json)
    }

    override fun onChangePinStarted() {
        Log.i("RealAusweisAppSDK", "Change PIN workflow started")
    }

    override fun onAccessRights(error: String?, accessRights: AccessRights?) {
        Log.d("RealAusweisAppSDK", "Access rights received. Error: $error")
        val json = JSONObject()
        json.put("msg", "ACCESS_RIGHTS")
        error?.let { json.put("error", it) }
        // accessRights details could be added here if needed
        sendToFlutter(json)
    }

    override fun onCertificate(certificateDescription: CertificateDescription) {}

    override fun onInsertCard(error: String?) {
        Log.d("RealAusweisAppSDK", "Requesting card insertion. Error: $error")
        val json = JSONObject()
        json.put("msg", "INSERT_CARD")
        error?.let { json.put("error", it) }
        sendToFlutter(json)
    }

    override fun onPause(cause: Cause) {
        Log.d("RealAusweisAppSDK", "Workflow paused. Cause: $cause")
    }

    override fun onReader(reader: SdkReader?) {
        Log.d("RealAusweisAppSDK", "Reader update: ${reader?.name}, card available: ${reader?.card != null}")
        val json = JSONObject()
        json.put("msg", "READER")
        json.put("name", reader?.name)
        val cardJson = JSONObject()
        cardJson.put("available", reader?.card != null)
        json.put("card", cardJson)
        sendToFlutter(json)
    }

    override fun onReaderList(readers: List<SdkReader>?) {
        Log.d("RealAusweisAppSDK", "Reader list update. Count: ${readers?.size ?: 0}")
    }

    override fun onEnterPin(error: String?, reader: SdkReader) {
        Log.i("RealAusweisAppSDK", "Requesting PIN entry")
        val json = JSONObject()
        json.put("msg", "ENTER_PIN")
        json.put("reader", reader.name)
        error?.let { json.put("error", it) }
        sendToFlutter(json)
    }

    override fun onEnterNewPin(error: String?, reader: SdkReader) {
        Log.i("RealAusweisAppSDK", "Requesting NEW PIN entry")
        val json = JSONObject()
        json.put("msg", "ENTER_NEW_PIN")
        sendToFlutter(json)
    }

    override fun onEnterPuk(error: String?, reader: SdkReader) {
        Log.i("RealAusweisAppSDK", "Requesting PUK entry")
        val json = JSONObject()
        json.put("msg", "ENTER_PUK")
        sendToFlutter(json)
    }

    override fun onEnterCan(error: String?, reader: SdkReader) {
        Log.i("RealAusweisAppSDK", "Requesting CAN entry")
        val json = JSONObject()
        json.put("msg", "ENTER_CAN")
        sendToFlutter(json)
    }

    override fun onChangePinCompleted(changePinResult: ChangePinResult) {}

    override fun onWrapperError(error: WrapperError) {
        Log.e("RealAusweisAppSDK", "Wrapper error: ${error.error} in ${error.msg}")
        val json = JSONObject()
        json.put("msg", "INTERNAL_ERROR")
        json.put("error", error.error)
        sendToFlutter(json)
    }

    override fun onStatus(workflowProgress: WorkflowProgress) {
        Log.d("RealAusweisAppSDK", "Workflow status: ${workflowProgress.workflow}, progress: ${workflowProgress.progress}")
    }

    override fun onInfo(versionInfo: SdkVersionInfo) {
        Log.i("RealAusweisAppSDK", "SDK Info: ${versionInfo.name} ${versionInfo.implementationVersion}")
        val json = JSONObject()
        json.put("msg", "INFO")
        val vInfo = JSONObject()
        vInfo.put("Name", versionInfo.name)
        vInfo.put("Implementation-Version", versionInfo.implementationVersion)
        json.put("VersionInfo", vInfo)
        sendToFlutter(json)
    }

    override fun onInternalError(error: String) {
        Log.e("RealAusweisAppSDK", "Internal SDK error: $error")
    }

    override fun onBadState(error: String) {
        Log.e("RealAusweisAppSDK", "Bad state error: $error")
        val json = JSONObject()
        json.put("msg", "BAD_STATE")
        json.put("error", error)
        sendToFlutter(json)
    }
}

class MainActivity: FlutterActivity() {
    private val channel = "com.example.stimmapp/eid"
    private var eidController: EidController? = null
    private var interaction: FlutterEidInteraction? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
        val interaction = FlutterEidInteraction(methodChannel)
        this.interaction = interaction
        
        val sdkWrapper = RealAusweisAppSdkWrapper(this)
        
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