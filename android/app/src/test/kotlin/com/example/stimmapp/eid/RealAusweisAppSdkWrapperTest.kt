package com.example.stimmapp.eid

import android.content.Context
import com.governikus.ausweisapp.sdkwrapper.card.core.WorkflowController
import com.example.stimmapp.RealAusweisAppSdkWrapper
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.mockito.kotlin.*
import org.json.JSONObject

class RealAusweisAppSdkWrapperTest {
    private val mockContext = mock<Context>()
    private val mockWorkflowController = mock<WorkflowController>()

    @Test
    fun `test initialization starts workflow controller`() {
        RealAusweisAppSdkWrapper(mockContext, mockWorkflowController)
        
        verify(mockWorkflowController).registerCallbacks(any())
        verify(mockWorkflowController).start(mockContext)
    }

    @Test
    fun `test sendCommand GET_INFO`() {
        val wrapper = RealAusweisAppSdkWrapper(mockContext, mockWorkflowController)
        wrapper.sendCommand("{\"cmd\": \"GET_INFO\"}")
        
        verify(mockWorkflowController).getInfo()
    }

    @Test
    fun `test sendCommand RUN_AUTH`() {
        val wrapper = RealAusweisAppSdkWrapper(mockContext, mockWorkflowController)
        wrapper.sendCommand("{\"cmd\": \"RUN_AUTH\", \"tcTokenURL\": \"https://test.url\"}")
        
        verify(mockWorkflowController).startAuthentication(any())
    }

    @Test
    fun `test callback translation AUTH_SUCCESS`() {
        val wrapper = RealAusweisAppSdkWrapper(mockContext, mockWorkflowController)
        var capturedMessage: String? = null
        wrapper.setCallback { capturedMessage = it }
        
        val mockAuthResult = mock<com.governikus.ausweisapp.sdkwrapper.card.core.AuthResult>()
        val mockResult = mock<com.governikus.ausweisapp.sdkwrapper.card.core.AuthResultData>()
        whenever(mockAuthResult.result).thenReturn(mockResult)
        whenever(mockResult.major).thenReturn("ok")
        
        wrapper.onAuthenticationCompleted(mockAuthResult)
        
        val json = JSONObject(capturedMessage!!)
        assertTrue(json.getString("msg") == "AUTH_SUCCESS")
    }

    @Test
    fun `test callback translation READER`() {
        val wrapper = RealAusweisAppSdkWrapper(mockContext, mockWorkflowController)
        var capturedMessage: String? = null
        wrapper.setCallback { capturedMessage = it }
        
        val mockReader = mock<com.governikus.ausweisapp.sdkwrapper.card.core.Reader>()
        whenever(mockReader.name).thenReturn("NFC Reader")
        whenever(mockReader.card).thenReturn(null)
        
        wrapper.onReader(mockReader)
        
        val json = JSONObject(capturedMessage!!)
        assertTrue(json.getString("msg") == "READER")
        assertTrue(json.getString("name") == "NFC Reader")
        assertTrue(!json.getJSONObject("card").getBoolean("available"))
    }

    @Test
    fun `test callback translation ENTER_PIN`() {
        val wrapper = RealAusweisAppSdkWrapper(mockContext, mockWorkflowController)
        var capturedMessage: String? = null
        wrapper.setCallback { capturedMessage = it }
        
        val mockReader = mock<com.governikus.ausweisapp.sdkwrapper.card.core.Reader>()
        whenever(mockReader.name).thenReturn("NFC Reader")
        
        wrapper.onEnterPin(null, mockReader)
        
        val json = JSONObject(capturedMessage!!)
        assertTrue(json.getString("msg") == "ENTER_PIN")
        assertTrue(json.getString("reader") == "NFC Reader")
    }
}
