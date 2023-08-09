package com.example.test_env

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class MyReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        // This method is called when the BroadcastReceiver is receiving an Intent broadcast.
        if (intent.action == "com.example.test_env.ACTION_INCREASE") {
            Log.d("BROADCAST RECEIVER","Increase requested")
        }
    }
}