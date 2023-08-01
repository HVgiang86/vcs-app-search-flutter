package com.example.test_env.database

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.util.Log
import com.example.test_env.model.WeatherInfo

class WeatherSQLiteHelper(context: Context?) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {

    companion object {
        private const val DATABASE_NAME = "weather_db"
        private const val DATABASE_VERSION = 1
        private const val TABLE_NAME = "weather_info"

        private const val KEY_LOCATION = "location"
        private const val KEY_COUNTRY = "country"
        private const val KEY_LAST_UPDATE = "last_update"
        private const val KEY_TEMP_C = "temp_c"
        private const val KEY_WIN_DEGREE = "wind_degree"
        private const val KEY_WIN_DIR = "wind_dir"
        private const val KEY_CLOUD = "cloud"
        private const val KEY_UV = "uv"
    }

    override fun onCreate(p0: SQLiteDatabase?) {
        val sqlCreate = String.format("CREATE TABLE %s (\n" + "    %s TEXT PRIMARY KEY,\n" + "    %s TEXT,\n" + "    %s TEXT,\n" + "    %s REAL,\n" + "    %s INTEGER,\n" + "    %s TEXT,\n" + "    %s INTEGER,\n" + "    %s REAL\n" + ")", TABLE_NAME, KEY_LAST_UPDATE, KEY_LOCATION, KEY_COUNTRY, KEY_TEMP_C, KEY_WIN_DEGREE, KEY_WIN_DIR, KEY_CLOUD, KEY_UV)
        p0?.execSQL(sqlCreate)
    }

    override fun onUpgrade(p0: SQLiteDatabase?, p1: Int, p2: Int) {
        val sqlDrop = java.lang.String.format("DROP TABLE IF EXISTS %s", TABLE_NAME)
        p0?.execSQL(sqlDrop)

        onCreate(p0)
    }

    fun addRecord(w: WeatherInfo) {
        val content = ContentValues()
        content.put(KEY_LOCATION, w.location)
        content.put(KEY_CLOUD, w.cloud)
        content.put(KEY_COUNTRY, w.country)
        content.put(KEY_UV, w.uv)
        content.put(KEY_LAST_UPDATE, w.lastUpdate)
        content.put(KEY_TEMP_C, w.tempC)
        content.put(KEY_WIN_DIR, w.windDir)
        content.put(KEY_WIN_DEGREE, w.windDegree)

        writableDatabase.insert(TABLE_NAME, null, content)
        writableDatabase.close()
    }

    fun readOldest(): WeatherInfo? {
        val cursor = readableDatabase.query(TABLE_NAME, null, null, null, null, null, KEY_LAST_UPDATE)
        if (cursor != null) {
            cursor.moveToFirst()
            Log.d("SQLite", "number of records: ${cursor.count}")
            val w = WeatherInfo(lastUpdate = cursor.getString(0), location = cursor.getString(1), country = cursor.getString(2), tempC = cursor.getFloat(3), windDegree = cursor.getInt(4), windDir = cursor.getString(5), cloud = cursor.getInt(6), uv = cursor.getFloat(7))
            cursor.close()
            return w
        }
        return null
    }



}