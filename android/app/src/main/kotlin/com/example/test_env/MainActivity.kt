package com.example.test_env

import android.util.Log
import com.example.test_env.database.WeatherSQLiteHelper
import com.example.test_env.model.WeatherInfo
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val MESSAGE_REQUEST = "com.example.test_env/message_request"
    private val UPDATE_REQUEST = "com.example.test_env/update_sqlite"
    private val READ_REQUEST = "com.example.test_env/read_sqlite"
    private val apiMethod = "apiHandle"
    private val messageParam = "messageParam"

    private val REQUEST_METHOD_KEY = "request_method_key"
    private val REQUEST_BODY_KEY = "request_body_key"

    private val sqlHelper = WeatherSQLiteHelper(this)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MESSAGE_REQUEST).setMethodCallHandler { call, result ->
            run {
                if (call.method == apiMethod) {
                    val message = call.argument<String>(messageParam)
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
    }

    private fun apiHandle(messageParam: String): String? {
        if (messageParam.isEmpty() || messageParam == null) {
            Log.d("API Handle","messageParam empty")
            return null}

        Log.d("API Handle","messageParam: $messageParam")

        val request = messageParamParser(messageParam)

        if (request[REQUEST_METHOD_KEY] == UPDATE_REQUEST) {
            val weather = WeatherInfo.jsonParse(request[REQUEST_BODY_KEY] as JSONObject)
            sqlHelper.addRecord(weather)

            return "success"
        } else if (request[REQUEST_METHOD_KEY] == READ_REQUEST) {
            val weather = sqlHelper.readOldest()
            return weather?.toJSON()?.toString()
        }

        return null
    }

    private fun messageParamParser(messageParam: String): Map<String, Any> {
        val map = HashMap<String, Any>()
        val root = JSONObject(messageParam)
        map[REQUEST_METHOD_KEY] = root[REQUEST_METHOD_KEY]
        val strRequestBody = root[REQUEST_BODY_KEY].toString()
        val jsonObj = JSONObject(strRequestBody)
        map[REQUEST_METHOD_KEY] = jsonObj

        return map
    }
}
