package com.example.stimmapp.eid

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.argumentCaptor
import org.mockito.kotlin.any

class EidControllerTest {
    private val mockSdk = mock<AusweisAppSdkWrapper>()
    private val mockInteraction = mock<EidInteraction>()

    @Test
    fun `test controller initialization`() {
        val controller = EidController(mockSdk, mockInteraction)
        assertEquals(false, controller.isSessionStarted)
        verify(mockSdk).setCallback(any())
    }

    @Test
    fun `test startVerification sends command`() {
        val controller = EidController(mockSdk, mockInteraction)
        
        controller.startVerification("https://test.url") {}
        
        assertEquals(true, controller.isSessionStarted)
        verify(mockSdk).sendCommand("{\"cmd\": \"RUN_AUTH\", \"tcTokenURL\": \"https://test.url\"}")
    }

    @Test
    fun `test handle success message`() {
        val callbackCaptor = argumentCaptor<(String) -> Unit>()
        val controller = EidController(mockSdk, mockInteraction)
        verify(mockSdk).setCallback(callbackCaptor.capture())

        var result: String? = "Initial"
        controller.startVerification("url") { result = it }
        
        callbackCaptor.firstValue.invoke("{\"msg\": \"AUTH_SUCCESS\"}")
        
        assertEquals("Success", result)
        assertEquals(false, controller.isSessionStarted)
    }

    @Test
    fun `test handle access rights message`() {
        val callbackCaptor = argumentCaptor<(String) -> Unit>()
        val controller = EidController(mockSdk, mockInteraction)
        verify(mockSdk).setCallback(callbackCaptor.capture())

        controller.startVerification("url") { }
        
        callbackCaptor.firstValue.invoke("{\"msg\": \"ACCESS_RIGHTS\"}")
        
        verify(mockSdk).sendCommand("{\"cmd\": \"ACCEPT_RIGHTS\"}")
    }

    @Test
    fun `test handle insert card message`() {
        val callbackCaptor = argumentCaptor<(String) -> Unit>()
        val controller = EidController(mockSdk, mockInteraction)
        verify(mockSdk).setCallback(callbackCaptor.capture())

        controller.startVerification("url") { }
        
        callbackCaptor.firstValue.invoke("{\"msg\": \"INSERT_CARD\"}")
    }

    @Test
    fun `test handle enter pin message`() {
        val callbackCaptor = argumentCaptor<(String) -> Unit>()
        val controller = EidController(mockSdk, mockInteraction)
        verify(mockSdk).setCallback(callbackCaptor.capture())

        controller.startVerification("url") { }
        
        callbackCaptor.firstValue.invoke("{\"msg\": \"ENTER_PIN\"}")
        
        val pinCaptor = argumentCaptor<(String) -> Unit>()
        verify(mockInteraction).onRequestPin(pinCaptor.capture())
        
        pinCaptor.firstValue.invoke("123456")
        verify(mockSdk).sendCommand("{\"cmd\": \"SET_PIN\", \"value\": \"123456\"}")
    }

    @Test
    fun `test handle enter can message`() {
        val callbackCaptor = argumentCaptor<(String) -> Unit>()
        val controller = EidController(mockSdk, mockInteraction)
        verify(mockSdk).setCallback(callbackCaptor.capture())

        controller.startVerification("url") { }
        
        callbackCaptor.firstValue.invoke("{\"msg\": \"ENTER_CAN\"}")
        
        val canCaptor = argumentCaptor<(String) -> Unit>()
        verify(mockInteraction).onRequestCan(canCaptor.capture())
        
        canCaptor.firstValue.invoke("123456")
        verify(mockSdk).sendCommand("{\"cmd\": \"SET_CAN\", \"value\": \"123456\"}")
    }

    @Test
    fun `test handle enter puk message`() {
        val callbackCaptor = argumentCaptor<(String) -> Unit>()
        val controller = EidController(mockSdk, mockInteraction)
        verify(mockSdk).setCallback(callbackCaptor.capture())

        controller.startVerification("url") { }
        
        callbackCaptor.firstValue.invoke("{\"msg\": \"ENTER_PUK\"}")
        
        val pukCaptor = argumentCaptor<(String) -> Unit>()
        verify(mockInteraction).onRequestPuk(pukCaptor.capture())
        
        pukCaptor.firstValue.invoke("1234567890")
        verify(mockSdk).sendCommand("{\"cmd\": \"SET_PUK\", \"value\": \"1234567890\"}")
    }

    @Test
    fun `test handle reader message`() {
        val callbackCaptor = argumentCaptor<(String) -> Unit>()
        val controller = EidController(mockSdk, mockInteraction)
        verify(mockSdk).setCallback(callbackCaptor.capture())

        callbackCaptor.firstValue.invoke("{\"msg\": \"READER\", \"name\": \"NFC Reader\", \"card\": {\"available\": true}}")
        
        verify(mockInteraction).onReaderInfo("NFC Reader", true)
    }

    @Test
    fun `test handle card message`() {
        val callbackCaptor = argumentCaptor<(String) -> Unit>()
        val controller = EidController(mockSdk, mockInteraction)
        verify(mockSdk).setCallback(callbackCaptor.capture())

        callbackCaptor.firstValue.invoke("{\"msg\": \"INSERT_CARD\"}")
        // INSERT_CARD usually happens when card is missing
        
        // Let's say we get a READER message with card: available: true
        callbackCaptor.firstValue.invoke("{\"msg\": \"READER\", \"name\": \"NFC\", \"card\": {\"available\": true}}")
        verify(mockInteraction).onCardDetected()
    }

    @Test
    fun `test handle onMessage notification`() {
        val callbackCaptor = argumentCaptor<(String) -> Unit>()
        val controller = EidController(mockSdk, mockInteraction)
        verify(mockSdk).setCallback(callbackCaptor.capture())

        val message = "{\"msg\": \"SOME_OTHER_MESSAGE\"}"
        callbackCaptor.firstValue.invoke(message)
        
        verify(mockInteraction).onMessage(message)
    }
}
