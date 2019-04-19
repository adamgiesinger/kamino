import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/main.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/util/settings.dart';

class Trakt {

  static Future<Map<String, String>> _getAuthHeaders(BuildContext context) async {
    KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());
    var traktCredentials = await Settings.traktCredentials;

    return {
      HttpHeaders.authorizationHeader: 'Bearer ${traktCredentials[0]}',
      HttpHeaders.contentTypeHeader: 'application/json',
      'trakt-api-version': '2',
      'trakt-api-key': appState.getPrimaryVendorConfig().getTraktCredentials().id
    };
  }

  static Future<bool> isAuthenticated() async {
    return (await ((Settings.traktCredentials) as Future)).length == 3;
  }

  static Future<List<ContentModel>> getWatchHistory(BuildContext context, { bool includeComplete = false }) async {
    List<ContentModel> progressData = [];

    try {
      // Generate Trakt authentication headers.
      var headers = await _getAuthHeaders(context);

      // Make GET request to history endpoint.
      var responseRaw = await http.get("https://api.trakt.tv/sync/history/", headers: headers);
      List<dynamic> response = jsonDecode(responseRaw.body);

      for(Map<String, dynamic> entry in response){
        if(entry["type"] == 'episode'){
          if(progressData.where((_entry) => _entry.id == entry["show"]["ids"]["tmdb"]).length > 0) continue;

          var content = await TMDB.getContentInfo(context, ContentType.TV_SHOW, entry["show"]["ids"]["tmdb"]);

          var progressResponse = jsonDecode((await http.get("https://api.trakt.tv/shows/${entry["show"]["ids"]["trakt"].toString()}/progress/watched", headers: headers)).body);
          content.progress = (double.parse(progressResponse["completed"].toString()) / double.parse(progressResponse["aired"].toString()));
          content.lastWatched = progressResponse["last_watched_at"];

          if(content.progress < 1 || includeComplete) progressData.add(content);
        }
      }

      return progressData;
    }catch(ex){
      print(ex);
      throw new Exception("An error occurred whilst connecting to Trakt.tv.");
    }
  }

}