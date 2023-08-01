package com.example.test_env.model

import org.json.JSONObject

data class WeatherInfo(var location: String = "undefined", var country: String = "undefined", var lastUpdate: String = "undefined", var tempC: Double = 0.0, var windDegree: Int = 0, var windDir: String = "undefined", var cloud: Int = 0, var uv: Double = 0.0) {
    companion object{
        fun jsonParse(obj: JSONObject):WeatherInfo {
            val location = obj["location"] as String
            val country = obj["country"] as String
            val lastUpdate = obj["last_update"] as String
            val tempC = obj["temp_c"] as Double
            val windDegree = obj["wind_degree"] as Int
            val windDir = obj["wind_dir"] as String
            val cloud = obj["cloud"] as Int
            val uv = obj["uv"] as Double

            return WeatherInfo(location, country, lastUpdate, tempC, windDegree, windDir, cloud, uv)
        }
    }

    fun toJSON(): JSONObject {
        val root = JSONObject()
        root.put("location",location)
        root.put("country",country)
        root.put("last_update",lastUpdate)
        root.put("temp_c",tempC)
        root.put("wind_degree",windDegree)
        root.put("wind_dir",windDir)
        root.put("cloud",cloud)
        root.put("uv",uv)
        return root
    }


}


