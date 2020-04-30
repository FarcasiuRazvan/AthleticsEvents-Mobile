import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:convert';
import 'dart:io';
import 'AthleticEvent.dart';


void main() async => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventsList',
      home: AthleticsEvents(),
    );
  }
}
class AthleticsEvents extends StatefulWidget{
  @override
  AthleticsEventsState createState() => AthleticsEventsState();
}

class AthleticsEventsState extends State<AthleticsEvents> {
//  final _events = <AthleticEvent>[
//    AthleticEvent(title:"European Athletics Championships",url_photo:"logo.jpg",description:"EUROPEAN1"),
//    AthleticEvent(title:"European Athletics Indoors",url_photo:"logo.jpg",description:"EUROPEAN2"),
//    AthleticEvent(title:"European Athletics Team Championships",url_photo:"logo.jpg",description:"EUROPEAN3"),
//    AthleticEvent(title:"Spar European Cross Country Championships",url_photo:"logo.jpg",description:"EUROPEAN4"),
//    AthleticEvent(title:"European Athletics u23 Championships",url_photo:"logo.jpg",description:"EUROPEAN5"),
//    AthleticEvent(title:"European Athletics u20 Championships",url_photo:"logo.jpg",description:"EUROPEAN6"),
//    AthleticEvent(title:"European Athletics u18 Championships",url_photo:"logo.jpg",description:"EUROPEAN7"),
//    AthleticEvent(title:"European Athletics Team Championships First League",url_photo:"logo.jpg",description:"EUROPEAN8"),
//    AthleticEvent(title:"European Athletics Team Championships Second League",url_photo:"logo.jpg",description:"EUROPEAN9"),
//    AthleticEvent(title:"European Athletics Team Championships Third League",url_photo:"logo.jpg",description:"EUROPEAN10")
//  ];
  var _events=<AthleticEvent>[];
  var _toPost=<AthleticEvent>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  DatabaseHelper database=new DatabaseHelper();
  BuildContext _context;
  bool a;
  //172.30.116.83
  static final String urlBasedOnPlatform = Platform.isAndroid ? "192.168.1.7" : "localhost";
  static String baseUrl= "http://"+urlBasedOnPlatform+":3000/events";
  @override
  Widget build(BuildContext context){
    _context=context;
    return Scaffold(
      appBar: AppBar(
        title: Text('Athletics Events'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: _addForm),
          IconButton(icon: Icon(Icons.remove), onPressed: _deleteForm),
          IconButton(icon: Icon(Icons.update), onPressed: _updateForm),
        ],
      ),
      body: _buildEvents(),
    );
  }
  void _addForm(){
    for(int i=0;i<_toPost.length;i++)
      _makePostRequestOnline(_toPost[i]);
    Navigator.of(_context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context){
              String title="";
              String photo="";
              String description="";
              return Scaffold(
                appBar: AppBar(
                  title: Text('Add Event'),
                ),
                body: Container(
                  child: Column(
                    children:[
                      Text('Title'),
                      TextField(onChanged: (v) => title=v),
                      Text('Photo URL'),
                      TextField(onChanged: (v) => photo=v),
                      Text('Description'),
                      TextField(onChanged: (v) => description=v)
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: ()=>setState(()=>{
                    for(int i=0;i<_toPost.length;i++)
                      _makePostRequestOnline(_toPost[i]),
                    print("ToInsert: "+title+" "+photo+" "+description),
                    _addEvent(AthleticEvent(title:title, url_photo:photo, description:description, serverId: "0")),
                    Navigator.pop(context, false)
                  }),
                  child: const Icon(Icons.add),
                ),
              );

            }
        )
    );
  }
  void _addEvent(AthleticEvent ev) async {
    if(!_events.contains(ev)) {
      _events.add(ev);
      database.insertEvent(ev,"events_table");
      await _makePostRequest(ev);
      print("chestie");
    }
  }

  void _deleteForm(){
    for(int i=0;i<_toPost.length;i++)
      _makePostRequestOnline(_toPost[i]);
    Navigator.of(_context).push(
      MaterialPageRoute<void>(
          builder: (BuildContext context){
            String title="";
            return Scaffold(
              appBar: AppBar(
                title: Text('Delete Event'),
              ),
              body: Container(
                child: Column(
                  children:[
                    Text('Title'),
                    TextField(onChanged: (v) => title=v)

                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: ()=>setState(()=>{
                  for(int i=0;i<_toPost.length;i++)
                    _makePostRequestOnline(_toPost[i]),
                  print("ToDelete: "+title),
                  _deleteEvent(AthleticEvent(title:title,url_photo: "",description: "",serverId: "0")),
                  Navigator.pop(context, false)
                }),
                child: const Icon(Icons.delete),
              ),
            );
          }
        )
    );
  }
  void _deleteEvent(AthleticEvent ev) async {
    bool isInternet=await checkIfInternet();
    if(isInternet==true)
    {
      int index=0;
      String serverId="";
      for(int i=0;i<_events.length;i++)
        if(_events[i].title==ev.title) {
          index = i;
          serverId = _events[i].serverId;
        }
      String urlToAcces = baseUrl +"/"+serverId;
      print("Delete Event -> urlToAcces: "+urlToAcces);

      _events.removeAt(index);
      database.deleteEvent(ev.title,"events_table");
      Response response = await delete(urlToAcces);
      if(response.statusCode==200)
      {
          _events.removeAt(index);
          database.deleteEvent(ev.title,"events_table");
      }
      else{
        throw "Couldn't delete";
      }
    }
  }
  void _updateForm(){
    for(int i=0;i<_toPost.length;i++)
      _makePostRequestOnline(_toPost[i]);
    Navigator.of(_context).push(
      MaterialPageRoute<void>(
          builder: (BuildContext context){
            String title="";
            String photo="";
            String description="";
            return Scaffold(
              appBar: AppBar(
                title: Text('Update Event'),
              ),
              body: Container(
                child: Column(
                  children:[
                    Text('Title'),
                    TextField(onChanged: (v) => title=v),
                    Text('Photo'),
                    TextField(onChanged: (v) => photo=v),
                    Text('Description'),
                    TextField(onChanged: (v) => description=v)
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: ()=>setState(()=>{
                  for(int i=0;i<_toPost.length;i++)
                    _makePostRequestOnline(_toPost[i]),
                  print("ToUpdate: "+title+" "+photo+" "+description),
                  _updateEvent(AthleticEvent(title:title, url_photo:photo, description:description, serverId: "0")),
                  Navigator.pop(context, false)
                }),
                child: const Icon(Icons.update),
              ),
            );
          }
        )
    );
  }
  void _updateEvent(AthleticEvent ev)async {
    _makePostRequest(ev);
  }

  void _pushEvent(AthleticEvent ev){
    Navigator.of(_context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context){
              return Scaffold(
                appBar: AppBar(
                  title: Text(ev.title),
                ),
                body: Column(
                  children: [
                    Text(ev.url_photo),
                    Text(ev.description)
                  ],
                )
              );

            }
        )
    );
  }

  Widget _buildEvents(){
    database.getEventsList().then((result){
      setState(() {
        _events=result;
      });
    });
    database.getEventsToPostList().then((result){
      setState(() {
        _toPost=result;
      });
    });
    return ListView.builder(itemBuilder: (context,i){
      if(_events.length>i) return _buildRow(_events[i]);
    });
  }
  Widget _buildRow(AthleticEvent ev){
    return ListTile(
      title: Text(ev.title, style: _biggerFont),
      onTap: (){
        setState(() {
          _pushEvent(ev);
        });
      },
    );

  }

  Future <bool> checkIfInternet() async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none){
      return false;
    }
    else return true;
  }

  Future<void> _makePostRequest(AthleticEvent athleticEvent) async {
    // set up POST request arguments
    print("why???");
    bool isInternet=await checkIfInternet();
    print("why1???");
    if(isInternet==true) {
      String url = baseUrl;
      var uri = Uri.parse(url);
      print(uri.host);
      print(uri.port);
      Map<String, String> headers = {"Content-type": "application/json"};
      // make POST request
      print("why2???");
      Map<String, dynamic> jsonStr={
        'title' : athleticEvent.title,
        'photo_url' : athleticEvent.url_photo,
        'description' : athleticEvent.description
      };
      print(json.encode(jsonStr));
      Response response = await post(url, headers: headers, body: json.encode(jsonStr));
      print("why3???");
      //check the status code for the result
      int statusCode = response.statusCode;
      if(statusCode==200){
        dynamic body = jsonDecode(response.body);
        print("The event "+body.toString()+" was added succesfully !!");
        athleticEvent.serverId=body["_id"].toString();
        database.updateEvent(athleticEvent);
        for(int i=0;i<_events.length;i++)
          if(_events[i].title==athleticEvent.title)
          {
            print("Servere: "+_events[i].serverId+" "+athleticEvent.serverId);
            _events[i].title=athleticEvent.title;
            _events[i].description=athleticEvent.description;
            _events[i].url_photo=athleticEvent.url_photo;
            _events[i].serverId=athleticEvent.serverId;
            break;
          }
      }
      else{
        throw "Couldn't add event\n The reason"+response.body+"\n";
      }
    }
    else{
      int ok=1;
      for(int i=0;i<_toPost.length;i++)
        if(_toPost[i].title==athleticEvent.title)
          ok=0;
      if(ok==1) {
        _toPost.add(athleticEvent);
        database.insertEvent(athleticEvent, "to_post_table");
      }
    }
  }
  Future<void> _makePostRequestOnline(AthleticEvent athleticEvent) async {
    // set up POST request arguments
    print("postOnline "+_toPost.length.toString());
    bool isInternet=await checkIfInternet();
    if(isInternet==true) {
      print("postOnline with internet");
      String url = baseUrl;
      var uri = Uri.parse(url);
      print(uri.host);
      print(uri.port);
      Map<String, String> headers = {"Content-type": "application/json"};
      // make POST request
      Map<String, dynamic> jsonStr={
        'title' : athleticEvent.title,
        'photo_url' : athleticEvent.url_photo,
        'description' : athleticEvent.description
      };
      print(json.encode(jsonStr));
      Response response = await post(url, headers: headers, body: json.encode(jsonStr));
      //check the status code for the result
      int statusCode = response.statusCode;
      if(statusCode==200){
        print("postOnline connection succesfully");
        dynamic body = jsonDecode(response.body);
        print("The event "+body.toString()+" was added succesfully !!");
        athleticEvent.serverId=body["_id"].toString();
        database.updateEvent(athleticEvent);
        for(int i=0;i<_events.length;i++)
          if(_events[i].title==athleticEvent.title)
          {
            print("Servere: "+_events[i].serverId+" "+athleticEvent.serverId);
            _events[i].title=athleticEvent.title;
            _events[i].description=athleticEvent.description;
            _events[i].url_photo=athleticEvent.url_photo;
            _events[i].serverId=athleticEvent.serverId;
            print("postOnline event added to the server");
            break;
          }
        for(int i=0;i<_toPost.length;i++)
          if(_toPost[i].title==athleticEvent.title)
            {
              database.deleteEvent(_toPost[i].title, "to_post_table");
              _toPost.removeAt(i);
              print("postOnline event deleted from local db");
              break;
            }

      }
      else{
        throw "Couldn't add event\n The reason"+response.body+"\n";
      }
    }
    else{
      int ok=1;
      for(int i=0;i<_toPost.length;i++)
        if(_toPost[i].title==athleticEvent.title)
          ok=0;
      if(ok==1) {
        _toPost.add(athleticEvent);
        database.insertEvent(athleticEvent, "to_post_table");
      }
    }
  }


}

