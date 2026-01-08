package com.example.stimmapp.eid

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper

class FlutterEidInteraction(private val channel: MethodChannel) : EidInteraction {
    private val handler = Handler(Looper.getMainLooper())
    private var pinCallback: ((String) -> Unit)? = null
    private var canCallback: ((String) -> Unit)? = null
    private var pukCallback: ((String) -> Unit)? = null

    override fun onRequestPin(onPinEntered: (String) -> Unit) {
        pinCallback = onPinEntered
        handler.post { channel.invokeMethod("onRequestPin", null) }
    }

    override fun onRequestCan(onCanEntered: (String) -> Unit) {
        canCallback = onCanEntered
        handler.post { channel.invokeMethod("onRequestCan", null) }
    }

    override fun onRequestPuk(onPukEntered: (String) -> Unit) {
        pukCallback = onPukEntered
        handler.post { channel.invokeMethod("onRequestPuk", null) }
    }

    override fun onCardDetected() {
        handler.post { channel.invokeMethod("onCardDetected", null) }
    }

    override fun onCardLost() {
        handler.post { channel.invokeMethod("onCardLost", null) }
    }

    override fun onReaderInfo(name: String, cardAvailable: Boolean) {
        handler.post {
            channel.invokeMethod("onReaderInfo", mapOf("name" to name, "cardAvailable" to cardAvailable))
        }
    }

    override fun onMessage(message: String) {
        handler.post { channel.invokeMethod("onMessage", message) }
    }

    fun setPin(pin: String) {
        pinCallback?.invoke(pin)
        pinCallback = null
    }

    fun setCan(can: String) {
        canCallback?.invoke(can)
        canCallback = null
    }

    fun setPuk(puk: String) {
        pukCallback?.invoke(puk)
        pukCallback = null
    }
}

fun processUserName(
    call: MethodCall,
    result: MethodChannel.Result
) {
    // Your code here
    var userName1: String

    @Suppress("UNCHECKED_CAST")
    val arguments = call.arguments as? List<Map<String, Any>> ?: emptyList()
    userName1 = arguments.firstOrNull()?.get("text") as? String ?: "defaultUser"
    println("Received userName::: $userName1")
    val resultMap = mapOf("userName" to userName1)
    result.success(resultMap)
}