import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AthleticEvent{
  String title;
  String url_photo;
  String description;
  String category;
  String serverId="0";

  AthleticEvent({
    this.title,
    this.url_photo,
    this.description,
    this.category,
    this.serverId
  });
  String get titlu => title;
  String get photo => url_photo;
  String get descriere => description;
  String get categorie => category;
  String get serverID => serverId;

  factory AthleticEvent.fromJson(Map <String, dynamic> data) => new AthleticEvent(
    title: data["title"],
    url_photo: data["url_photo"],
    description: data["description"],
    category: data["category"],
    serverId: data["serverId"],
  );

  Map<String, dynamic> toJson()=>{
    "title":title,
    "url_photo":url_photo,
    "description":description,
    "category":category,
    "serverId":serverId
  };
}

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;
  static Database _database;

  String eventsTable = 'events_table';
  String toPostTable='to_post_table';
  String colId = 'id';
  String colTitle = 'title';
  String colPhoto = 'url_photo';
  String colDescription = 'description';
  String colCategory = 'category';
  String colServerId = 'serverId';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {

    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {

    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'athletics_events4.db';

    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {

    await db.execute('CREATE TABLE $toPostTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colPhoto TEXT, $colDescription TEXT, $colCategory TEXT, $colServerId TEXT)');
    await db.execute('CREATE TABLE $eventsTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colPhoto TEXT, $colDescription TEXT, $colCategory TEXT, $colServerId TEXT)');
  }

  Future<List<Map<String, dynamic>>> getEventsMapList(String table) async {
    Database db = await this.database;
    var result = await db.query(table);
    return result;
  }

  Future<int> insertEvent(AthleticEvent ev,String table) async {
    Database db = await this.database;
    var result = await db.insert(table, ev.toJson());
    return result;
  }

  Future<int> updateEvent(AthleticEvent ev) async {
    var db = await this.database;
    print("Update Database: "+ev.photo+" "+ev.description+" "+ev.title+" "+ev.category+" "+ev.serverId);
    var result = await db.rawUpdate('UPDATE events_table SET url_photo = ?, description = ?, category = ?, serverId = ? WHERE title = ?',[ev.photo,ev.description,ev.category,ev.serverId,ev.title]);
    return result;
  }

  Future<int> deleteEvent(String title, String table) async {
    var db = await this.database;
    print("DELETE EVENT "+title);
    int result = await db.rawDelete('DELETE FROM $table WHERE title = ?',[title]);
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $eventsTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getCountToPost() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $toPostTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<AthleticEvent>> getEventsList() async {

    var noteMapList = await getEventsMapList(eventsTable);
    int count = noteMapList.length;

    List<AthleticEvent> noteList = List<AthleticEvent>();
    for (int i = 0; i < count; i++) {
      var titlu=noteMapList.elementAt(i)["title"];
      var url_photo=noteMapList.elementAt(i)["url_photo"];
      var description=noteMapList.elementAt(i)["description"];
      var serverId=noteMapList.elementAt(i)["serverId"];
      var category=noteMapList.elementAt(i)["category"];
      noteList.add(AthleticEvent(title:titlu,url_photo: url_photo,description: description,serverId: serverId,category: category));
    }

    return noteList;
  }

  Future<List<AthleticEvent>> getEventsToPostList() async {

    var noteMapList = await getEventsMapList(toPostTable);
    int count = noteMapList.length;

    List<AthleticEvent> noteList = List<AthleticEvent>();
    for (int i = 0; i < count; i++) {
      var titlu=noteMapList.elementAt(i)["title"];
      var url_photo=noteMapList.elementAt(i)["url_photo"];
      var description=noteMapList.elementAt(i)["description"];
      var serverId=noteMapList.elementAt(i)["serverId"];
      var category=noteMapList.elementAt(i)["category"];
      noteList.add(AthleticEvent(title:titlu,url_photo: url_photo,description: description,serverId: serverId,category: category));
    }

    return noteList;
  }

  Future<List<AthleticEvent>> getEventsByCategoryList(String categ) async {

    var noteMapList = await getEventsMapList(eventsTable);
    int count = noteMapList.length;

    List<AthleticEvent> noteList = List<AthleticEvent>();
    for (int i = 0; i < count; i++) {
      var titlu=noteMapList.elementAt(i)["title"];
      var url_photo=noteMapList.elementAt(i)["url_photo"];
      var description=noteMapList.elementAt(i)["description"];
      var serverId=noteMapList.elementAt(i)["serverId"];
      var category=noteMapList.elementAt(i)["category"];
      if(category==categ) noteList.add(AthleticEvent(title:titlu,url_photo: url_photo,description: description,serverId: serverId,category: category));
    }

    return noteList;
  }
}







