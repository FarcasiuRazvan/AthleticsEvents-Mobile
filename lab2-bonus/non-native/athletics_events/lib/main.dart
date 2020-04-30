import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
      //debugShowCheckedModeBanner: false,
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
  DatabaseHelper database=new DatabaseHelper();
  BuildContext _context;
  bool a;
  var dropdown=['100m Sprint','200m Sprint','400m Sprint'].map((value)
  {
    return new DropdownMenuItem(
      value:value,
      child: new Text(value, style: TextStyle(fontWeight: FontWeight.bold,)),
    );
  }).toList();
  String category;
  String categoryEvents="general";
  String title="";
  String photo="";
  String description="";
  bool isDarkTheme=true;
  bool isBlind=true;
  Color textColor=Colors.black;
  Color textListColor=Colors.black;
  Color backGroundColor=Colors.blue;
  Color listColor=Colors.lightBlueAccent;
  var sizeText=16.0;
  var sizeTitleAppBar=22.0;
  var sizeTitle=22.0;
  //172.30.116.83
  static final String urlBasedOnPlatform = Platform.isAndroid ? "192.168.1.7" : "localhost";
  static String baseUrl= "http://"+urlBasedOnPlatform+":3000/events";
  @override
  Widget build(BuildContext context){
    _context=context;
//    return MaterialApp(
//      theme: isDarkTheme ?
//      ThemeData(
//          brightness: Brightness.light,
//          primaryColor: Colors.blue,
//      ) :
//      ThemeData(
//        brightness: Brightness.dark,
//      ),
//        home:
    return Container(
    color:listColor,
        child:Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(90.0), // here the desired height
            child: AppBar(
              backgroundColor: backGroundColor,
              title: Text('Athletics \n Events',style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitleAppBar,color: textColor),),
              actions: <Widget>[
                Switch(
                  value: isDarkTheme,
                  onChanged: (value){
                    isDarkTheme=value;
                    value ? backGroundColor=Colors.blue : backGroundColor=Colors.black;
                    value ? listColor=Colors.lightBlueAccent : listColor=Colors.black45;
                    value ? textColor=Colors.black : textColor=Colors.white;
                  },
                  activeTrackColor: Colors.lightBlue,
                  inactiveTrackColor: Colors.white,
                  activeColor: Colors.lightBlueAccent,
                ),
                Switch(
                  value: isBlind,
                  onChanged: (value){
                    isBlind=value;
                    value ? sizeText=16.0 : sizeText=30.0;
                    value ? sizeTitle=22.0: sizeTitle=35.0;
                    value ? sizeTitleAppBar=22.0: sizeTitleAppBar=26.0;
                  },
                  activeTrackColor: Colors.lightBlue,
                  inactiveTrackColor: Colors.white,
                  activeColor: Colors.lightBlueAccent,
                ),
                IconButton(icon: Icon(Icons.add), onPressed: _addForm),
      //          IconButton(icon: Icon(Icons.remove), onPressed: _deleteForm),
      //          IconButton(icon: Icon(Icons.update), onPressed: _updateForm),
              ],
            ),
          ),
          body: _buildEvents(),
          drawer: Drawer(
            child: Container(
              color:listColor,
              child:ListView(
                children: <Widget>[
                  DrawerHeader(
                    child: Text(
                        'Categories',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitle,color: textColor),
                      textAlign: TextAlign.center,

                    ),
                    decoration: BoxDecoration(
                      color: backGroundColor,
                    )
                  ),
                  ListTile(
                      title: Text('General',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeText,color: textColor),
                      ),
                      onTap:(){
                        categoryEvents="general";
                        Navigator.pop(context);
                      }
                  ),
                  ListTile(
                    title: Text('100m Sprint',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeText,color: textColor),
                    ),
                    onTap:(){
                      categoryEvents="100m Sprint";
                      Navigator.pop(context);
                    }
                  ),
                  ListTile(
                      title: Text('200m Sprint',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeText,color: textColor),
                      ),
                      onTap:(){
                        categoryEvents="200m Sprint";
                        Navigator.pop(context);
                      }
                  ),
                  ListTile(
                      title: Text('400m Sprint',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeText,color: textColor),
                      ),
                      onTap:(){
                        categoryEvents="400m Sprint";
                        Navigator.pop(context);
                      }
                  ),
                ]
              ),
            )
          ),

        ),
    );
  }
  void _addForm(){
    for(int i=0;i<_toPost.length;i++)
      _makePostRequestOnline(_toPost[i]);
    Navigator.of(_context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context){
              return MaterialApp(
                  theme: isDarkTheme ?
                  ThemeData(
                  brightness: Brightness.light,
                  primaryColor: Colors.blue,
              ) :
              ThemeData(
              brightness: Brightness.dark,
              ),
              home:Scaffold(
                  appBar: AppBar(
                    title: Text('Add Event'),
                  ),
                  body: Container(
                    child: Column(
                      children:[
                        Text('Title',style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitle,color: textColor),),
                        TextField(onChanged: (v) => title=v),
                        Text('Photo URL',style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitle,color: textColor),),
                        TextField(onChanged: (v) => photo=v),
                        Text('Description',style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitle,color: textColor),),
                        TextField(onChanged: (v) => description=v),
                        Text('Category',style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitle,color: textColor),),
                        DropdownButton(
                          items: dropdown,
                          onChanged: (String newValue){
                            print(title+" "+photo+" "+description);
                            setState(() {
                              print(title+" "+photo+" "+description);
                              category = newValue;
                              print("changed: "+category);
                            });
                          },
                          hint: Text("Select category",style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeText,color: textColor),),
                          value: category,
                        )
                      ],
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: ()=>setState(()=>{
                      if(category!=null && title!="" && photo!="" && description!="")
                        {
                          print("ToInsert: " + title + " " + photo + " " +description + " " + category),
                          for(int i = 0; i < _toPost.length; i++)
                          _makePostRequestOnline(_toPost[i]),
                          _addEvent(AthleticEvent(title: title,
                              url_photo: photo,
                              description: description,
                              category: category,
                              serverId: "0")),
                          category=null,
                        },
                      Navigator.pop(context, false)
                    }),
                    child: const Icon(Icons.add),
                  ),
                )
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
                  _deleteEvent(AthleticEvent(title:title,url_photo: "",description: "",category:"",serverId: "0")),
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
  void _updateForm(String title) async {
    bool isInternet=await checkIfInternet();
    if(isInternet==true)
    {
      for(int i=0;i<_toPost.length;i++)
        _makePostRequestOnline(_toPost[i]);
      Navigator.of(_context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context){
              return MaterialApp(
                  theme: isDarkTheme ?
                  ThemeData(
                  brightness: Brightness.light,
                  primaryColor: Colors.blue,
              ) :
              ThemeData(
              brightness: Brightness.dark,
              ),
              home:Scaffold(
                  appBar: AppBar(
                    title: Text('Update Event',style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitle,color: textColor),),
                  ),
                  body: Container(
                    child: Column(
                      children:[
                        Text('Photo URL',style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitle,color: textColor),),
                        TextField(onChanged: (v) => photo=v),
                        Text('Description',style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitle,color: textColor),),
                        TextField(onChanged: (v) => description=v),
                        Text('Category',style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitle,color: textColor),),
                        DropdownButton(
                          hint: Text("Select category",style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitle,color: textColor),),
                          value: category,
                          items: dropdown,
                          onChanged: (String newValue){
                            print(title+" "+photo+" "+description);
                            setState(() {
                              print(title+" "+photo+" "+description);
                              category = newValue;
                              print("changed: "+category);
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: ()=>setState(()=>{
                      if(title!="" && photo!="" && description!="" && category!=null)
                        {for(int i = 0; i < _toPost.length; i++)
                          _makePostRequestOnline(_toPost[i]),
                          print("ToUpdate: " + title + " " + photo + " " +
                              description + " " + category),
                          _updateEvent(AthleticEvent(title: title,
                              url_photo: photo,
                              description: description,
                              category: category,
                              serverId: "0")),
                          category=null,
                        },
                      Navigator.pop(context, false)
                    }),
                    child: const Icon(Icons.update),
                  ),
                )
              );
            }
          )
      );
    }
  }
  void _updateEvent(AthleticEvent ev)async {
    _makePostRequest(ev);
  }

  void _pushEvent(AthleticEvent ev){
    Navigator.of(_context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context){
              return MaterialApp(
                  theme: isDarkTheme ?
                  ThemeData(
                  brightness: Brightness.light,
                  primaryColor: Colors.blue,
              ) :
              ThemeData(
              brightness: Brightness.dark,
              ),
              home:Scaffold(
                  appBar: AppBar(
                    title: Text(ev.title,style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeTitleAppBar,color: textColor),),
                  ),
                  body: Column(
                    children: [
                      //Image.asset('assets/'+ev.url_photo),
                      Center(child: FadeInImage.assetNetwork(
                          fadeInDuration:
                            const Duration(seconds: 2),
                          fadeInCurve: Curves.bounceIn,
                          placeholder: 'assets/gifs/loading.gif',
                          image: ev.url_photo
                      )),
                      Text(ev.description,style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeText,color: textColor),)
                    ],
                  )
                ),
              );

            }
        )
    );
  }

  Widget _buildEvents(){
    //print("WWWWUUUTTTT");
    if(categoryEvents!="general")
    {
      database.getEventsByCategoryList(categoryEvents).then((result){
        setState(() {
          _events=result;
        });
      });
    }
    else{
      database.getEventsList().then((result){
        setState(() {
          _events=result;
        });
      });
    }
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
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          child: ListTile(
            title: Text(ev.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: sizeText,color: textListColor),),
            onTap: (){
              setState(() {
                _pushEvent(ev);
              });
            }
          ),
        actions: <Widget>[
          IconSlideAction(
          caption: 'Update',
            color: Colors.blue,
            icon: Icons.update,
            onTap: () {
                _updateForm(ev.title);
            },
          ),
          ],
          secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
              _deleteEvent(ev);
            }
          ),
          ],
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
        'description' : athleticEvent.description,
        'category' : athleticEvent.category
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
            _events[i].category=athleticEvent.category;
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
        'description' : athleticEvent.description,
        'category' : athleticEvent.category
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
            _events[i].category=athleticEvent.category;
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

