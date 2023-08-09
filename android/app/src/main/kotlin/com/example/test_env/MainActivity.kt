package com.example.test_env

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.core.content.ContextCompat
import com.example.test_env.database.WeatherSQLiteHelper
import com.example.test_env.model.WeatherInfo
import com.example.test_env.services.CountService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val MESSAGE_REQUEST = "com.example.test_env/message_request"
    private val UPDATE_REQUEST = "com.example.test_env/update_sqlite"
    private val OPEN_NOTIFICATION_REQUEST = "com.example.test_env/notification"
    private val READ_REQUEST = "com.example.test_env/read_sqlite"
    private val apiMethod = "apiHandle"
    private val messageParam = "messageParam"

    private val REQUEST_METHOD_KEY = "request_method_key"
    private val REQUEST_BODY_KEY = "request_body_key"

    private val sqlHelper = WeatherSQLiteHelper(this)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, MESSAGE_REQUEST
        ).setMethodCallHandler { call, result ->
            run {
                if (call.method == apiMethod) {
                    val message = call.argument<String>(messageParam)
                    if (!call.hasArgument(messageParam)) {
                        Log.d("API Handle", "not have argument")
                    }
                    val r = apiHandle(message!!)

                    if (r == null) {
                        result.error(
                            "fail run", "failed to call method", "detail not implement yet"
                        )
                    } else {
                        result.success(r)
                    }
                } else {
                    result.error(
                        "method not found",
                        "cannot to fail method ${call.method}",
                        "$apiMethod is required"
                    )
                }

            }
        }
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
}
