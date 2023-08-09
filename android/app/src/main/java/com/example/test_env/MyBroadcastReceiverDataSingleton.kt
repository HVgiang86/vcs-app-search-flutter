package com.example.test_env

object MyBroadcastReceiverDataSingleton {
    lateinit var listener: MyReceiver.EventSendable

    fun setup(listener: MyReceiver.EventSendable) {
        this.listener = listener
    }

    fun sendEvent(event: String) {
        listener.onEventSent(event)
    }
}