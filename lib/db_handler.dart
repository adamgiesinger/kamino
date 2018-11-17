import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';


class DBHelper{

  static Database _db;

  Future<Database> get db async {

    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  //Create a database in directory
  initDb() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "database.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }
  
  //Create all the tables in the database
  void _onCreate(Database db, int version) async {
    
    //Create the favourites table
    await db.execute("CREATE TABLE favourites (imdbId TEXT, name TEXT, posterUrl"
        "	TEXT, tmdbId	INTEGER, tvdbId	INTEGER,"
        " type	TEXT, year	INTEGER, user	TEXT)");

    print("Favourites table created");
  }

  //Retrieving favourite
  Future<List<String>>  getFavourites() async {
    List<String> _favourites = new List();

    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery("select tmdbId FROM "
        "favourites WHERE tmdbId is not null");

    for(int i = 0; i <list.length; i++){
      _favourites.add(list[i]["tmdbId"].toString());
    }

    List<Map> list2 = await dbClient.rawQuery("select imdbId FROM "
        "favourites WHERE imdbId is not null");

    for(int i = 0; i <list.length; i++){
      _favourites.add(list[i]["imdbId"].toString());
    }

    List<Map> list3 = await dbClient.rawQuery("select tvdbID FROM "
        "favourites WHERE tvdbID is not null");

    for(int i = 0; i <list.length; i++){
      _favourites.add(list[i]["tvdbID"].toString());
    }

    return _favourites;
  }

  void saveFavourite(NewFavourite fav) async {
    var dbClient = await db;

    await dbClient.transaction((txn) async {
      int id = await txn.rawInsert(
          "INSERT INTO favourites(imdbID,name,posterUrl,tmdbId,"
              "tvdbId,type,year,user) VALUES(?,?,?,?,?,?,?,?)",
          [fav.imdbId,fav.name,fav.posterUrl,fav.type,
          fav.user,fav.tmdbId,fav.tvdbID,fav.year]);

      print("inserted: $id");
    });
  }
  
}

class NewFavourite {
  String imdbId, name, posterUrl, type, user;
  int tmdbId, tvdbID, year;

  NewFavourite(this.imdbId, this.name, this.posterUrl, this.type, this.user,
      this.tmdbId, this.tvdbID, this.year);
}

