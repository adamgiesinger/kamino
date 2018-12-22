import 'package:objectdb/objectdb.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


saveFavourites(String name, String contentType, int tmdbid, String url) async{

  //get the path of the database file
  Directory documentDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentDirectory.path, "assets/apolloDB.db");
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
  Directory documentDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentDirectory.path, "assets/apolloDB.db");
  var db = ObjectDB(path);

  //open connection to the database
  db.open();

  var results = await db.find({
    Op.lte: {"docType": "favourites", "tmdbID":tmdbid}
  });

  print("found the following entries... $results");

  db.close();
  
  
  //return true if the show is a known favourite, else return false
  return results.length > 0 ? true : false;
}

removeFavourite(int tmdbid) async {

  //get the path of the database file
  Directory documentDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentDirectory.path, "assets/apolloDB.db");
  var db = ObjectDB(path);

  //open connection to the database
  db.open();
  
  //remove the item from the database
  db.remove({"docType": "favourites", "tmdbID":tmdbid});

  // 'tidy up' the db file
  db.tidy();

  db.close();
}