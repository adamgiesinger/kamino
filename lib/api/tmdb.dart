import 'dart:convert' as Convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kamino/main.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/models/list.dart';
import 'package:kamino/models/movie.dart';
import 'package:kamino/models/tvshow.dart';

class TMDB {

  static const String ROOT_URL = "https://api.themoviedb.org/3";
  static const String IMAGE_CDN = "https://image.tmdb.org/t/p/original";
  static const String IMAGE_CDN_LOWRES = "https://image.tmdb.org/t/p/w500";
  static const String IMAGE_CDN_POSTER = "https://image.tmdb.org/t/p/w300";

  /// You will need to define the API key in your vendor configuration file.
  /// Check our documentation for more information.
  static String getDefaultArguments(BuildContext context) {
    KaminoAppState application = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());
    return "?api_key=${application.getPrimaryVendorConfig().getTMDBKey()}&language=en-US";
  }

  // These lists are curated by the ApolloTV team and you're welcome to use them.
  // Otherwise, you can replace them by supplying an array of TMDB list IDs.
  static const List<String> curatedTMDBLists = [
    // ApolloTV Top Picks
    "107032",
    // Netflix Top Picks
    "105608",
    // New HD releases
    "105604",
    // 2019 Awards Seasons
    "105805",
    // Reddit Top 250
    "105619",
    // Disney & Friends
    "105547",
    // Marvel Cinematic Universe
    "105602",
    // Marvel Comics
    "105603",
    // DC Comics
    "105614",
  ];


  static Future<dynamic> getList(BuildContext context, String id, { bool loadFully = false, bool raw = false }) async {
    var rawContentResponse = (await http.get("https://api.themoviedb.org/4/list/$id${getDefaultArguments(context)}", headers: {
    'Content-Type': 'application/json;charset=utf-8'
    })).body;

    if(raw) return rawContentResponse;
    ContentListModel listModel = ContentListModel.fromJSON(Convert.jsonDecode(rawContentResponse));

    if(!listModel.fullyLoaded && loadFully){
      List<ContentModel> fullContentList = new List();

      // (TMDB starts at index of 1 *sigh*)
      for(int i = 1; i < listModel.totalPages; i++){
        // Make a request to TMDB for the desired page.
        var sublistContentResponse = (await http.get("https://api.themoviedb.org/4/list/$id${getDefaultArguments(context)}&page=$i", headers: {
          'Content-Type': 'application/json;charset=utf-8'
        })).body;

        // Cast the results into a list.
        List sublistContent = Convert.jsonDecode(sublistContentResponse)["results"];

        // Map the list items to ContentModels and add all the items to fullContentList.
        fullContentList.addAll(sublistContent.map((contentItem) => contentItem['media_type'] == 'movie'
          ? MovieContentModel.fromJSON(contentItem)
          : TVShowContentModel.fromJSON(contentItem)
        ).toList());
      }

      // Finally, update the ContentListModel's content item.
      listModel.content = fullContentList;
    }

    return listModel;
  }

  static Future<ContentModel> getContentInfo(BuildContext context, ContentType type, int id, { String appendToResponse }) async {
    // Get the data from the server.
    http.Response response = await http.get(
        "${TMDB.ROOT_URL}/${getRawContentType(type)}/$id${getDefaultArguments(context)}"
            + (appendToResponse != null ? "&append_to_response=$appendToResponse,external_ids,alternative_titles" : "&append_to_response=external_ids,alternative_titles")
    );
    String json = response.body;

    if (type == ContentType.MOVIE)
      // Return movie content model.
      return MovieContentModel.fromJSON(
          Convert.jsonDecode(json)
      );
    else if (type == ContentType.TV_SHOW)
      // Return TV show content model.
      return TVShowContentModel.fromJSON(
          Convert.jsonDecode(json)
      );

    throw new Exception("Invalid content type: $type");
  }

  static List<String> getAlternativeTitles(ContentModel model){
    List<String> result = [];
    
    if(model.alternativeTitles == null || model.alternativeTitles.length == 0)
      return result;

    List<LocalizedTitleModel> alternativeTitles = model.alternativeTitles;

    // Select up to 3 English titles
    result.addAll(
      alternativeTitles.where(
        (LocalizedTitleModel title) => title.iso_3166_1 == "US"
      ).take(3).map((LocalizedTitleModel title) => title.title).toList()
    );

    print(alternativeTitles.map((LocalizedTitleModel title) => title.iso_3166_1).toList());
    print(model.originalCountry);

    // ...and up to 2 titles from the native locale.
    result.addAll(
        alternativeTitles.where(
                (LocalizedTitleModel title) => title.iso_3166_1 == model.originalCountry
        ).take(2).map((LocalizedTitleModel title) => title.title).toList()
    );

    if(!result.contains(model.originalTitle))
      result = [model.originalTitle] + result;
    return result;
  }

}