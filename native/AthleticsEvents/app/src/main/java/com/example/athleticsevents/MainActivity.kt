package com.example.athleticsevents

import android.app.Activity
import android.app.AlertDialog
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.android.synthetic.main.activity_display_create.*
import kotlinx.android.synthetic.main.activity_main.*
import java.util.concurrent.Executors
//dependecy set in build.gradle(Module: app)
import okhttp3.*
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException

/*
val sportsEvents: ArrayList<AthleticEventClass> = arrayListOf(
    AthleticEventClass("European Athletics Championships","logo.jpg","EUROPEAN"),
    AthleticEventClass("European Athletics Indoors","logo.jpg","EUROPEAN"),
    AthleticEventClass("European Athletics Team Championships","logo.jpg","EUROPEAN"),
    AthleticEventClass("Spar European Cross Country Championships","logo.jpg","EUROPEAN"),
    AthleticEventClass("European Athletics u23 Championships","logo.jpg","EUROPEAN"),
    AthleticEventClass("European Athletics u20 Championships","logo.jpg","EUROPEAN"),
    AthleticEventClass("European Athletics u18 Championships","logo.jpg","EUROPEAN"),
    AthleticEventClass("European Athletics Team Championships First League","logo.jpg","EUROPEAN"),
    AthleticEventClass("European Athletics Team Championships Second League","logo.jpg","EUROPEAN"),
    AthleticEventClass("European Athletics Team Championships Third League","logo.jpg","EUROPEAN"))
*/
val sportsEvents: ArrayList<AthleticEventClass> = arrayListOf()
val sportsEventsToAdd: ArrayList<RequestBody> = arrayListOf()
var x= true
class MainActivity : AppCompatActivity() {

    val database = DatabaseHelper(this)
    override fun onCreate(savedInstanceState: Bundle?) {

        val listEvents=database.allData
//        Log.d("/LISTuta ",listEvents.getString(1))
        if(listEvents.moveToFirst() && x==true){
            x=false
            while(!listEvents.isAfterLast())
            {
                Log.d("LIST/EVENTS ",listEvents.getString(1))
                Log.d("LIST/EVENTS ",listEvents.getString(2))
                Log.d("LIST/EVENTS ",listEvents.getString(3))
                Log.d("LIST/EVENTS ",listEvents.getString(4))
                val title=listEvents.getString(1)
                val url=listEvents.getString(2)
                val description=listEvents.getString(3)
                val serverId=listEvents.getString(4)
                sportsEvents.add(AthleticEventClass(title,url,description,serverId))
                listEvents.moveToNext()
            }
        }
        listEvents.close()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val layoutManager=LinearLayoutManager(this)
        layoutManager.orientation=LinearLayoutManager.VERTICAL
        recyclerView.layoutManager=layoutManager
        recyclerView.adapter=EventsAdapter(sportsEvents, this)

    }
    override fun onResume(){
        super.onResume()
        if(isConnectedToNetwork()) {
            var beforeSize = sportsEvents.size
            for (x in 0..sportsEventsToAdd.size - 1) {
                Executors.newSingleThreadExecutor().execute {
                    POST("http://192.168.1.7:3000/events", sportsEventsToAdd[x])
                }
            }
            println(sportsEventsToAdd.size)
            if (sportsEvents.size == sportsEventsToAdd.size + beforeSize)
            {
                sportsEventsToAdd.clear()
            }
            loadAll()
        }
        recyclerView.adapter!!.notifyDataSetChanged()
    }

    fun remove(athleticEvent : AthleticEventClass){
        var i=0
        var size=sportsEvents.size
        while(i< size){
            if(sportsEvents[i].title == athleticEvent.title){
                var serverId= sportsEvents[i].serverId
                database.deleteData(sportsEvents[i].title)
                sportsEvents.removeAt(i)
                DELETE("http://192.168.1.7:3000/events/"+serverId.toString())
                recyclerView.adapter!!.notifyDataSetChanged()
                size-=1
                break
            }
            else i+=1
        }

    }
    fun update(athleticEvent : AthleticEventClass){
        var serverId="0"
        Log.d("MAIN/","ajunge aici"+athleticEvent.title)
        for(i in 0..sportsEvents.size-1){
            if(sportsEvents[i].title == athleticEvent.title){
                serverId=sportsEvents[i].serverId
                sportsEvents[i]=athleticEvent
                database.updateData(i,sportsEvents[i].title, sportsEvents[i].url, sportsEvents[i].desc,
                    serverId)
                recyclerView.adapter!!.notifyDataSetChanged()
                var title= sportsEvents[i].title
                var url= sportsEvents[i].url
                var desc= sportsEvents[i].desc
                val jsonEvent="""{
                    "title": "$title",
                    "photo_url": "$url",
                    "description": "$desc"
                    }""".trimIndent()
                var requestBody = RequestBody.create(
                    MediaType.parse("application/json; charset=utf-8"),
                    jsonEvent
                )

                Executors.newSingleThreadExecutor().execute{
                    PUT("http://192.168.1.7:3000/events/$serverId", requestBody)
                }
                break
            }
        }
    }
    fun create(athleticEvent : AthleticEventClass){
        if(!sportsEvents.contains(athleticEvent)) {
            //sportsEvents.add(athleticEvent)
            recyclerView.adapter!!.notifyDataSetChanged()
            //database.insertData(athleticEvent.title, athleticEvent.url, athleticEvent.desc,athleticEvent.serverId)
            var title= athleticEvent.title
            var url= athleticEvent.url
            var desc= athleticEvent.desc
            val jsonEvent="""{
                        "title": "$title",
                        "photo_url": "$url",
                        "description": "$desc"
                        }""".trimIndent()
            var requestBody = RequestBody.create(
                MediaType.parse("application/json; charset=utf-8"),
                jsonEvent
            )
            if(isConnectedToNetwork())
            {
                Executors.newSingleThreadExecutor().execute{
                    POST("http://192.168.1.7:3000/events", requestBody)
                    recyclerView.adapter!!.notifyDataSetChanged()
                }
                //sportsEvents.add(athleticEvent)
            }
            else{
                sportsEventsToAdd.add(requestBody)
                sportsEvents.add(athleticEvent)
                recyclerView.adapter!!.notifyDataSetChanged()
            }
        }
    }

    fun createEvent(view: View){
        Log.d("MAIN/CREATE/EVENT ","MESSAGE")
        val intent= Intent(this, DisplayCreateActivity::class.java)
        startActivityForResult(intent,1)
    }

    fun updateEvent(view: View){
        Log.d("MAIN/Chestie ","2")
        val intent= Intent(this, DisplayUpdateActivity::class.java)
        startActivityForResult(intent,2)
    }

    fun deleteEvent(view: View){
        val intent= Intent(this, DisplayDeleteActivity::class.java)
        startActivityForResult(intent,3)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        Log.d("MAIN/onActivity","ajunge aici")
        if(resultCode ==Activity.RESULT_OK){
            val title=data!!.getStringExtra("title")
            val photo=data!!.getStringExtra("photo")
            val description=data!!.getStringExtra("description")
            val serverId=data!!.getStringExtra("serverId")
            Log.d("MAIN/IFFF",title+photo+description+serverId+requestCode.toString())

            if(requestCode==1) this.create(AthleticEventClass(title,photo,description,serverId))
            else{
                if(isConnectedToNetwork())
                {
                    if(requestCode==2) this.update(AthleticEventClass(title,photo,description,serverId))
                    if(requestCode==3) this.remove(AthleticEventClass(title,photo,description,serverId))
                }
                else{
                    val builder = AlertDialog.Builder(this@MainActivity)
                    builder.setMessage("No internet")
                    val dialog: AlertDialog = builder.create()
                    dialog.show()
                }
            }
        }
    }

    fun loadAll(){
        Executors.newSingleThreadExecutor().execute{
                GET("http://192.168.1.7:3000/events");
            }
    }
    fun GET(url:String){
        val client = OkHttpClient()
        val request = Request.Builder().url(url).get().build()
        val response = client.newCall(request).execute()
        val jsonDataString=response.body()?.string()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                val json = JSONArray(jsonDataString)
                var errors=json.join(",")
                throw Exception(errors)
            }

            override fun onResponse(call: Call, response: Response) {
                this@MainActivity.runOnUiThread(object : Runnable{
                    override fun run() {
                        sportsEvents.clear()
                        Log.d("/MAIN/responseGET",jsonDataString)
                        val json = JSONArray(jsonDataString)
                        for(i in 0..json.length()-1){
                            var ev=AthleticEventClass(
                                json.getJSONObject(i)["title"].toString(),
                                json.getJSONObject(i)["photo_url"].toString(),
                                json.getJSONObject(i)["description"].toString(),
                                json.getJSONObject(i)["_id"].toString()
                            )
                            sportsEvents.add(ev)
                        }
                        print(sportsEvents)
                        recyclerView.adapter!!.notifyDataSetChanged()
                    }
                })
            }
        })
    }
    fun POST(url: String, requestBody: RequestBody?) {
        Log.d("MAIN/POST/EVENT ",url)
        val client = OkHttpClient()
        val request = Request.Builder()
            .method("POST", requestBody)
            .url(url)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                print("Oh no! It failed, bici\n")
            }

            override fun onResponse(call: Call, response: Response) {
                this@MainActivity.runOnUiThread(object : Runnable {
                    override fun run() {
                        val jsonDataString = response.body()?.string()
                        Log.d("/MAIN/response",jsonDataString)
                        val json = JSONObject(jsonDataString)
                        var ev=AthleticEventClass(
                            json["title"].toString(),
                            json["photo_url"].toString(),
                            json["description"].toString(),
                            json["_id"].toString()
                        )
                        sportsEvents.add(ev)
                        var index=0
                        for(i in 0..sportsEvents.size-1){
                            if(sportsEvents[i].title==ev.title) index=i
                        }
                        database.updateData(index,ev.title,ev.url,ev.desc,ev.serverId)
                        recyclerView.adapter!!.notifyDataSetChanged()
                    }
                }
                )
            }
        })
        recyclerView.adapter!!.notifyDataSetChanged()
    }
    fun PUT(url: String, requestBody: RequestBody?) {
        val client = OkHttpClient()
        val request = Request.Builder()
            .method("PUT", requestBody)
            .url(url)
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                print("Oh no! It failed, bici2\n")
            }

            override fun onResponse(call: Call, response: Response) {
                this@MainActivity.runOnUiThread(object : Runnable {
                    override fun run() {
                        val jsonDataString = response.body()?.string()
                        println(jsonDataString)
                        val json = JSONObject(jsonDataString)
                        var ev=AthleticEventClass(
                            json["title"].toString(),
                            json["photo_url"].toString(),
                            json["description"].toString(),
                            json["_id"].toString()
                        )
                        var index = 0
                        for (x in 0..sportsEvents.size - 1) {
                            if (sportsEvents[x].title == ev.title)
                                index = x
                        }
                        sportsEvents.set(index, ev)
                        database.updateData(index,ev.title,ev.url,ev.desc,ev.serverId)
                        recyclerView.adapter!!.notifyDataSetChanged()
                    }
                })
            }
        })
        recyclerView.adapter!!.notifyDataSetChanged()
    }
    fun DELETE(url: String) {
        Log.d("MAIN/DELETE/EVENT ",url)
        val client = OkHttpClient()
        val request = Request.Builder()
            .url(url)
            .delete()
            .build()
        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {}
            override fun onResponse(call: Call, response: Response){
                Log.d("MAIN/DELETE?EVENT",response.body()?.string())
            }
        })
        recyclerView.adapter!!.notifyDataSetChanged()
    }
    fun Context.isConnectedToNetwork(): Boolean {
        val connectivityManager =
            this.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager?
        return connectivityManager?.activeNetworkInfo?.isConnectedOrConnecting() ?: false
    }
}