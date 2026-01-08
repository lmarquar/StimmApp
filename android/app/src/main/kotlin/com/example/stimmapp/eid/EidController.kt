package com.example.stimmapp.eid

import android.util.Log
import org.json.JSONObject

interface AusweisAppSdkWrapper {
    fun sendCommand(cmd: String)
    fun setCallback(callback: (String) -> Unit)
}

interface EidInteraction {
    fun onRequestPin(onPinEntered: (String) -> Unit)
    fun onRequestCan(onCanEntered: (String) -> Unit)
    fun onRequestPuk(onPukEntered: (String) -> Unit)
    fun onCardDetected()
    fun onCardLost()
    fun onReaderInfo(name: String, cardAvailable: Boolean)
    fun onMessage(message: String)
}

class EidController(
    private val sdk: AusweisAppSdkWrapper,
    private val interaction: EidInteraction
) {
    var isSessionStarted: Boolean = false
        private set

    private var resultCallback: ((String?) -> Unit)? = null

    init {
        sdk.setCallback { message ->
            handleMessage(message)
        }
    }

    fun startVerification(tcTokenURL: String, onResult: (String?) -> Unit) {
        isSessionStarted = true
        resultCallback = onResult
        sdk.sendCommand("{\"cmd\": \"RUN_AUTH\", \"tcTokenURL\": \"$tcTokenURL\"}")
    }

    fun getInfo() {
        sdk.sendCommand("{\"cmd\": \"GET_INFO\"}")
    }

    private fun handleMessage(message: String) {
        val json = try {
            JSONObject(message)
        } catch (e: Exception) {
            Log.e("EidController", "Failed to parse SDK message: $message", e)
            return
        }
        val msg = json.optString("msg")

        when (msg) {
            "AUTH_SUCCESS" -> {
                resultCallback?.invoke("Success")
                isSessionStarted = false
            }
            "ACCESS_RIGHTS" -> {
                sdk.sendCommand("{\"cmd\": \"ACCEPT_RIGHTS\"}")
            }
            "ENTER_PIN" -> {
                interaction.onRequestPin { pin ->
                    sdk.sendCommand("{\"cmd\": \"SET_PIN\", \"value\": \"$pin\"}")
                }
            }
            "ENTER_CAN" -> {
                interaction.onRequestCan { can ->
                    sdk.sendCommand("{\"cmd\": \"SET_CAN\", \"value\": \"$can\"}")
                }
            }
            "ENTER_PUK" -> {
                interaction.onRequestPuk { puk ->
                    sdk.sendCommand("{\"cmd\": \"SET_PUK\", \"value\": \"$puk\"}")
                }
            }
            "READER" -> {
                val name = json.optString("name")
                val card = json.optJSONObject("card")
                val cardAvailable = card?.optBoolean("available") ?: false
                interaction.onReaderInfo(name, cardAvailable)
                if (cardAvailable) {
                    interaction.onCardDetected()
                } else {
                    interaction.onCardLost()
                }
            }
            "INSERT_CARD" -> {
                // UI should be notified to insert card
            }
            "BAD_STATE" -> {
                resultCallback?.invoke(null)
                isSessionStarted = false
            }
            "CHANGE_PIN" -> {
                // Not handled yet but could be
            }
        }
        
        // Notify Flutter about any message if needed
        interaction.onMessage(message)

        // Keep old logic for compatibility with any tests I might have missed
        if (msg.isEmpty()) {
            if (message.contains("ERROR")) {
                resultCallback?.invoke(null)
                isSessionStarted = false
            }
        }
    }
}
