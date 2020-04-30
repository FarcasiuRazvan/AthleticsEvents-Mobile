package com.example.athleticsevents

import android.content.Context
import android.content.res.Resources
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.widget.ImageView
import android.widget.TextView

class DisplayEventInfo : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_display_event_info)

        val message= intent.getStringExtra("name")

        val description= intent.getStringExtra("description")

        val photo= intent.getStringExtra("photo")

        findViewById<TextView>(R.id.event_name_id).apply {
            text = message
        }
//        R.drawable.logo
        findViewById<ImageView>(R.id.imageView).apply {
            setImageResource(resIdByName("logo.jpg","drawable"))
//                resources.getIdentifier("logo.jpg","drawable","res/drawable"))
        }
        findViewById<TextView>(R.id.textView).apply {
            text = description
        }
    }
    fun Context.resIdByName(resIdName: String?, resType: String): Int{
        resIdName?.let{
            return resources.getIdentifier(it,resType,packageName)
        }
        throw Resources.NotFoundException()
    }
}
