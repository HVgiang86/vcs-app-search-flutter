package com.example.test_env

import android.R
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class MyService : Service() {

    val CHANNEL_ID = "ForegroundServiceChannel"

    override fun onCreate() {
        super.onCreate()
        Log.d("NOTICE", "onCreate")
    }

    override fun onBind(intent: Intent?): IBinder? {
        Log.d("NOTICE", "onBind")
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("NOTICE", "onStartCommand")
        val input = intent!!.getStringExtra("inputExtra")
        createNotificationChannel()

        val increaseIntent = Intent(this, MyReceiver::class.java)
        increaseIntent.action = "com.example.test_env.INCREASE_ACTION"

        val actionPendingIntent = PendingIntent.getBroadcast(this, 0, increaseIntent, PendingIntent.FLAG_IMMUTABLE)

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID).setContentTitle("VCS Notification").setContentText(input).setSmallIcon(R.drawable.ic_secure).setOngoing(true).addAction(R.drawable.ic_input_add, "increase", actionPendingIntent).build()
        startForeground(1, notification)
        //do heavy work on a background thread
        //stopSelf();
        //do heavy work on a background thread
        //stopSelf();
        return START_NOT_STICKY
    }

    private fun createNotificationChannel() {
        Log.d("NOTICE", "createNotificationChannel")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(CHANNEL_ID, "Foreground Service Channel", NotificationManager.IMPORTANCE_DEFAULT)
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }
}