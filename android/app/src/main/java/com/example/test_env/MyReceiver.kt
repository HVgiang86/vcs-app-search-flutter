package com.example.test_env

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class MyReceiver() : BroadcastReceiver() {


    interface EventSendable {
        fun onEventSent(s: String)
    }

    override fun onReceive(context: Context, intent: Intent) {
        // This method is called when the BroadcastReceiver is receiving an Intent broadcast.
        if (intent.action == "com.example.test_env.INCREASE_ACTION") {
            Log.d("BROADCAST RECEIVER", "Increase requested")

            val event = "increase_requested_event"
            MyBroadcastReceiverDataSingleton.sendEvent(event)
        }
    }


}