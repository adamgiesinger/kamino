import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kamino/main.dart';
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

  static void saveWatchProgress(BuildContext context) async {
    // Make GET request to playback sync endpoint
    var headers = await _getAuthHeaders(context);
    //var responseRaw = await http.get("https://api.trakt.tv/sync/playback/", headers: headers);
    var responseRaw = await http.get("https://private-anon-7b61b1f925-trakt.apiary-mock.com/sync/playback/");

    // Add TMDB ID and progress to database.
    List<dynamic> response = jsonDecode(responseRaw.body);
  }

}