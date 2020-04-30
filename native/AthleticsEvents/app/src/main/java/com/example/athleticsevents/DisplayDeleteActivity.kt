package com.example.athleticsevents

import android.app.Activity
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.EditText
import android.widget.TextView

class DisplayDeleteActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_display_delete)
    }

    fun delete(view: View){

        val name=findViewById<EditText>(R.id.titleDeleteId).text.toString()
        val intent = Intent(this, MainActivity::class.java).apply{
            putExtra("title",name)
            putExtra("photo","")
            putExtra("description","")
            putExtra("serverId","0")
            putExtra("action","delete")
        }
        setResult(Activity.RESULT_OK,intent)
        finish()
    }
}
