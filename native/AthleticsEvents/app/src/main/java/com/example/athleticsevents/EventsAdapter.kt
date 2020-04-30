package com.example.athleticsevents

import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.recyclerview.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import kotlinx.android.synthetic.main.list_item.view.*

const val EXTRA_EVENT="com.example.newapplication.MESSAGE"

class EventsAdapter(val items : ArrayList<AthleticEventClass>, val context : Context) :
    RecyclerView.Adapter<ViewHolder>(){
    override fun getItemCount(): Int {
        return items.size
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(LayoutInflater.from(context).inflate(R.layout.list_item, parent, false))
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val itemEvent=items.get(position)
        holder.bindTitle(itemEvent.title)
        holder.setTitle(itemEvent.title)
        holder.setDescription(itemEvent.desc)
        holder.setPhoto(itemEvent.url)
    }
}

class ViewHolder(view: View) : RecyclerView.ViewHolder(view), View.OnClickListener {
    public var v: View=view
    public var eventName: String = ""
    public var eventDescription: String = ""
    public var eventPhoto: String = ""
    init{
        view.setOnClickListener(this)
    }
    override fun onClick(v: View) {
        Log.d("RecyclerView","CLICK")
        val context=itemView.context

        val intent= Intent(context, DisplayEventInfo::class.java).apply{
            putExtra("name", eventName)
            putExtra("photo",eventPhoto)
            putExtra("description", eventDescription)
        }
        context.startActivity(intent)
    }
    fun bindTitle(text: String){
        v.title.text=text
    }
    fun setTitle(text: String){
        eventName=text
    }
    fun setDescription(text: String){
        eventDescription=text
    }
    fun setPhoto(text: String){
        eventPhoto=text
    }
}