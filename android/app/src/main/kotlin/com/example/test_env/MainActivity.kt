package com.example.test_env

import android.Manifest
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.test_env.database.WeatherSQLiteHelper
import com.example.test_env.model.WeatherInfo
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity(), MyReceiver.EventSendable {


    private val MESSAGE_REQUEST = "com.example.test_env/message_request"
    private val UPDATE_REQUEST = "com.example.test_env/update_sqlite"
    private val OPEN_NOTIFICATION_REQUEST = "com.example.test_env/notification"
    private val READ_REQUEST = "com.example.test_env/read_sqlite"
    private val apiMethod = "apiHandle"
    private val messageParam = "messageParam"

    private val REQUEST_METHOD_KEY = "request_method_key"
    private val REQUEST_BODY_KEY = "request_body_key"

    private val sqlHelper = WeatherSQLiteHelper(this)

    var receiver: MyReceiver = MyReceiver()
    var eventSink: EventChannel.EventSink? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MyBroadcastReceiverDataSingleton.setup(this)
        checkPermission(Manifest.permission.POST_NOTIFICATIONS, 1011)

        val intentFilter = IntentFilter()
        intentFilter.addAction("com.example.test_env.INCREASE_ACTION")
        registerReceiver(receiver, intentFilter)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(receiver)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MESSAGE_REQUEST).setMethodCallHandler { call, result ->
            run {
                if (call.method == apiMethod) {
                    val message = call.argument<String>(messageParam)
                    if (!call.hasArgument(messageParam)) {
                        Log.d("API Handle", "not have argument")
                    }
                    val r = apiHandle(message!!)

                    if (r == null) {
                        result.error("fail run", "failed to call method", "detail not implement yet")
                    } else {
                        result.success(r)
                    }
                } else {
                    result.error("method not found", "cannot to fail method ${call.method}", "$apiMethod is required")
                }
            }
        }

        val eventHandler = object : EventChannel.StreamHandler {
            var sink: EventChannel.EventSink? = null
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                sink = events
                eventSink = events
                sink?.success("on_listen")
                Log.d("Event Channel", "event channel onListen()")
            }

            override fun onCancel(arguments: Any?) {
                sink = null
            }
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.test_env/event_channel").setStreamHandler(eventHandler)
    }

    private fun apiHandle(messageParam: String): String? {
        if (messageParam.isEmpty()) {
            Log.d("API Handle", "messageParam empty")
            return null
        }

        Log.d("API Handle", "messageParam: $messageParam")

        val request = messageParamParser(messageParam)

        if (request[REQUEST_METHOD_KEY] == UPDATE_REQUEST) {

            val weather = WeatherInfo.jsonParse(request[REQUEST_BODY_KEY] as JSONObject)
            Log.d("API Handle", "sql add record requested. $weather")
            sqlHelper.addRecord(weather)

            return "success"
        } else if (request[REQUEST_METHOD_KEY] == READ_REQUEST) {
            val weather = sqlHelper.readOldest() ?: return null
            Log.d("API Handle", "sql read record requested. $weather")
            return weather.toJSON().toString()
        } else if (request[REQUEST_METHOD_KEY] == OPEN_NOTIFICATION_REQUEST) {
            Log.d("API Handle", "service requested")
            val serviceIntent = Intent(this, MyService::class.java)
            serviceIntent.putExtra("inputExtra", "Foreground Service Example in Android")
            ContextCompat.startForegroundService(this, serviceIntent)

            return "success"
        }

        return null
    }

    private fun messageParamParser(messageParam: String): Map<String, Any> {
        val map = HashMap<String, Any>()
        val root = JSONObject(messageParam)
        map[REQUEST_METHOD_KEY] = root[REQUEST_METHOD_KEY]
        val strRequestBody = root[REQUEST_BODY_KEY].toString()

        if (strRequestBody.isEmpty()) {
            map[REQUEST_BODY_KEY] = ""
        } else {
            val jsonObj = JSONObject(strRequestBody)
            map[REQUEST_BODY_KEY] = jsonObj
        }

        Log.d("API Handle", "$REQUEST_METHOD_KEY: ${map[REQUEST_METHOD_KEY]}")
        Log.d("API Handle", "$REQUEST_BODY_KEY: ${map[REQUEST_BODY_KEY]}")
        return map
    }

    private fun checkPermission(permission: String, requestCode: Int) {
        if (ContextCompat.checkSelfPermission(this@MainActivity, permission) == PackageManager.PERMISSION_DENIED) {
            // Requesting the permission
            ActivityCompat.requestPermissions(this@MainActivity, arrayOf(permission), requestCode)
        } else {
            Toast.makeText(this@MainActivity, "Permission already granted", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1011) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this@MainActivity, "Notification Permission Granted", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this@MainActivity, "Notification Permission Denied", Toast.LENGTH_SHORT).show()
            }
        }
    }

    fun sendEvent(s: String) {
        eventSink!!.success(s)
    }

    override fun onEventSent(s: String) {
        sendEvent(s)
    }
}
