import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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
      'trakt-api-key': appState.getVendorConfigs()[0].traktCredentials.id
    };
  }

  static Future<List<ContentModel>> getWatchProgress(BuildContext context) async {
    try {
      // Make GET request to playback sync endpoint
      var headers = await _getAuthHeaders(context);
      var responseRaw = await http.get("https://api.trakt.tv/sync/playback/", headers: headers);

      print(responseRaw.body);
      // Add TMDB ID and progress to database.
      List<dynamic> response = jsonDecode(responseRaw.body);

      return [];
    }catch(ex){
      throw new Exception("An error occurred whilst connecting to Trakt.tv.");
    }
  }

}