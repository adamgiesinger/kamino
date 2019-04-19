import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/models/content.dart';
import 'package:objectdb/objectdb.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {

  // GENERAL //
  static Future<ObjectDB> openDatabase() async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    return ObjectDB("${appDirectory.path}/apolloDB.db").open();
  }

  static Future<void> bulkWrite(List<Map> content) async {
    ObjectDB database = await openDatabase();
    await database.insertMany(content);
    database.close();
  }

  static Future<void> dump() async {
    print("Opening database...");
    ObjectDB database = await openDatabase();
    print("Dumping contents...");
    print((await database.find({})).toString());
  }

  static Future<void> wipe() async {
    ObjectDB database = await openDatabase();
    await database.remove({});
    await database.close();
  }

  // FAVORITES //
  static Future<void> saveFavoriteById(BuildContext context, ContentType type, int id) async {
    await saveFavorite(await TMDB.getContentInfo(context, type, id));
  }
  
  static Future<void> saveFavorite(ContentModel content) async {
    ObjectDB database = await openDatabase();

    Map dataEntry = FavoriteDocument.fromModel(content).toMap();
    await database.insert(dataEntry);

    database.close();
  }

  static Future<void> saveFavorites(List<FavoriteDocument> content) async {
    bulkWrite(content.map((FavoriteDocument document) => document.toMap()).toList());
  }

  static Future<bool> isFavorite(int tmdbId) async {
    ObjectDB database = await openDatabase();

    var results = await database.find({
      "docType": "favorites",
      "tmdbID": tmdbId
    });

    database.close();
    return results.length == 1 ? true : false;
  }

  static Future<void> removeFavorite(ContentModel model) async {
    await removeFavoriteById(model.id);
  }
  
  static Future<void> removeFavoriteById(int id) async {
    ObjectDB database = await openDatabase();
    database.remove({"docType": "favorites", "tmdbID": id});
    database.close();
  }

  static Future<Map<String, List<FavoriteDocument>>> getAllFavorites() async {
    return {
      'tv': await getFavoritesByType(ContentType.TV_SHOW),
      'movie': await getFavoritesByType(ContentType.MOVIE)
    };
  }

  static Future<List<int>> getAllFavoriteIds() async {
    ObjectDB database = await openDatabase();
    List<Map> results = await database.find({
      "docType": "favorites"
    });

    database.close();
    return results.map((Map result) => result['tmdbID'] as int).toList();
  }

  static Future<List<FavoriteDocument>> getFavoritesByType(ContentType type) async {
    ObjectDB database = await openDatabase();
    List<Map> results = await database.find({
      "docType": "favorites",
      "contentType": getRawContentType(type)
    });

    database.close();
    return results.map((Map result) => FavoriteDocument(result)).toList();
  }

  // SEARCH HISTORY //

  static Future<List<String>> getSearchHistory() async {
    ObjectDB database = await openDatabase();

    List<Map> results = await database.find({
      "docType": "pastSearch"
    });

    database.close();
    return results.map((Map result) => result['text']).toList();
  }

  static Future<void> writeToHistory(String text) async {
    ObjectDB database = await openDatabase();
    database.insert({
      "docType": "pastSearch",
      "text": text
    });
    database.close();
  }

  static Future<void> removeFromHistory(String text) async {
    ObjectDB database = await openDatabase();
    database.remove({
      "docType": "pastSearch",
      "text": text
    });
    database.close();
  }
}

class FavoriteDocument {

  int tmdbId;
  String name;
  ContentType contentType;
  String imageUrl;
  String year;
  DateTime savedOn;

  FavoriteDocument(Map data) :
    tmdbId = data['tmdbID'],
    name = data['name'],
    contentType = data['contentType'] == 'tv' ? ContentType.TV_SHOW : ContentType.MOVIE,
    imageUrl = data['imageUrl'],
    year = data['year'],
    savedOn = DateTime.parse(data['saved_on']);

  FavoriteDocument.fromModel(ContentModel model) :
    tmdbId = model.id,
    name = model.title,
    contentType = model.contentType,
    imageUrl = model.posterPath,
    year = DateFormat.y("en_US").format(DateTime.parse(model.releaseDate)),
    savedOn = DateTime.now().toUtc();

  Map toMap(){
    return {
      "docType": "favorites",
      "tmdbID": tmdbId,
      "name": name,
      "contentType": getRawContentType(contentType),
      "imageUrl": imageUrl,
      "year": year,
      "saved_on": savedOn.toString()
    };
  }

}