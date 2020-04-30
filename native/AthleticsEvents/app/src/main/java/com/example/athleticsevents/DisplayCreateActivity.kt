package com.example.athleticsevents

import android.app.Activity
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.EditText
import android.widget.TextView

class DisplayCreateActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_display_create)
    }

    fun save(view: View){
        val name=findViewById<EditText>(R.id.titleCreateId).text.toString()
        val photo=findViewById<EditText>(R.id.photoCreateId).text.toString()
        val description=findViewById<EditText>(R.id.descriptionCreateId).text.toString()
        val intent = Intent(this, MainActivity::class.java).apply{
            putExtra("title",name)
            putExtra("photo",photo)
            putExtra("description",description)
            putExtra("serverId","0")
            putExtra("action","create")
        }
        setResult(Activity.RESULT_OK,intent)
        finish()

    }
}
