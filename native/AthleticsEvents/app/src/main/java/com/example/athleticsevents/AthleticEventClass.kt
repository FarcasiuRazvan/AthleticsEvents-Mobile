package com.example.athleticsevents

import android.content.Context
import android.database.sqlite.SQLiteOpenHelper
import android.content.ContentValues
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import android.util.Log


class AthleticEventClass( name : String, urlPhoto : String, description : String, sId: String){
    val title : String
    val url : String
    val desc : String
    val serverId: String
    init{
        title=name
        url=urlPhoto
        desc=description
        serverId=sId
    }
}

class DatabaseHelper(context: Context) :
    SQLiteOpenHelper(context, "athletics_events3.db", null, 1) {

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL("CREATE TABLE events_table (ID INTEGER PRIMARY KEY AUTOINCREMENT,TITLE TEXT,PHOTO_URL TEXT,DESCRIPTION TEXT,SERVERID TEXT)")
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        db.execSQL("DROP TABLE IF EXISTS events_table")
        onCreate(db)
    }


    fun insertData(title: String, photo_url: String, description: String, serverId:String) {
        val db = this.writableDatabase
        val contentValues = ContentValues()
        contentValues.put("TITLE", title)
        contentValues.put("PHOTO_URL", photo_url)
        contentValues.put("DESCRIPTION", description)
        contentValues.put("SERVERID", serverId)
        db.insert("events_table", null, contentValues)
    }


    fun updateData(index: Int, title: String, photo_url: String, description: String, serverId: String):Boolean {
        val db = this.writableDatabase

        val contentValues = ContentValues()
        contentValues.put("ID", index)
        contentValues.put("TITLE", title)
        contentValues.put("PHOTO_URL", photo_url)
        contentValues.put("DESCRIPTION", description)
        contentValues.put("SERVERID", serverId)
        db.update("events_table", contentValues, "TITLE = ?", arrayOf(title))
        return true
    }


    fun deleteData(title : String) : Int {
        val db = this.writableDatabase
        return db.delete("events_table","TITLE = ?", arrayOf(title))
    }


    val allData : Cursor
        get() {
            val db = this.writableDatabase
            val res = db.rawQuery("SELECT * FROM events_table", null)
            return res
        }

}