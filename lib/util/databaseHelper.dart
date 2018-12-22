import 'package:objectdb/objectdb.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

Future saveFavourites(String name, String contentType, int tmdbid, String url) async{

  //get the path of the database file
  final directory = await getApplicationDocumentsDirectory();
  final path =  directory.path  + "/apolloDB.db";
  var db = ObjectDB(path);

  //open connection to the database
  db.open();

  Map dataEntry = {
    "name": name,
    "docType": "favourites",
    "contentType": contentType,
    "tmdbID": tmdbid,
    "imageUrl": url,
  };

  await db.insert(dataEntry);
  print("wrote $dataEntry to the database");

  // 'tidy up' the db file
  db.tidy();

  await db.close();
}

Future<bool> isFavourite(int tmdbid) async{

  //get the path of the database file
  final directory = await getApplicationDocumentsDirectory();
  final path =  directory.path  + "/apolloDB.db";
  var db = ObjectDB(path);

  //open connection to the database
  db.open();

  var results = await db.find({
        "docType": "favourites",
        "tmdbID":tmdbid
      });

  db.close();

  //return true if the show is a known favourite, else return false
  return results.length == 1 ? true : false;
}

Future removeFavourite(int tmdbid) async {

  //get the path of the database file
  final directory = await getApplicationDocumentsDirectory();
  final path =  directory.path  + "/apolloDB.db";
  var db = ObjectDB(path);

  //open connection to the database
  db.open();
  
  //remove the item from the database
  db.remove({"docType": "favourites", "tmdbID":tmdbid});

  // 'tidy up' the db file
  db.tidy();

  db.close();
}

Future<List<Map>> getFavMovies() async {

  //get the path of the database file
  final directory = await getApplicationDocumentsDirectory();
  final path =  directory.path  + "/apolloDB.db";
  var db = ObjectDB(path);

  db.open();

  List<Map> _result = await db.find({
    "docType": "favourites",
    "contentType": "movie"
  });

  db.close();

  return _result;
}

Future<List<Map>> getFavTVShows() async {

  //get the path of the database file
  final directory = await getApplicationDocumentsDirectory();
  final path =  directory.path  + "/apolloDB.db";
  var db = ObjectDB(path);

  db.open();

  List<Map> _result = await db.find({
    "docType": "favourites",
    "contentType": "tv"
  });

  db.close();

  return _result;
}