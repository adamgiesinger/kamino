import 'dart:convert' as Convert;

import 'package:http/http.dart' as http;
import 'package:kamino/models/content.dart';
import 'package:kamino/models/list.dart';
import 'package:kamino/models/movie.dart';
import 'package:kamino/models/tvshow.dart';
import 'package:kamino/vendor/index.dart';

class TMDB {

  static const String ROOT_URL = "https://api.themoviedb.org/3";
  static const String IMAGE_CDN = "https://image.tmdb.org/t/p/original";
  static const String IMAGE_CDN_LOWRES = "https://image.tmdb.org/t/p/w500";
  static const String IMAGE_CDN_POSTER = "https://image.tmdb.org/t/p/w300";

  /// You will need to define the API key in your vendor configuration file.
  /// Check our documentation for more information.
  static final String defaultArguments = "?api_key=${ApolloVendor.getTMDBKey()}&language=en-US";

  // These lists are curated by the ApolloTV team and you're welcome to use them.
  // Otherwise, you can replace them by supplying an array of TMDB list IDs.
  static const List<String> availableTraktLists = [
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


  static Future<ContentListModel> getList(String id, { bool loadFully = false }) async {
    var rawContentResponse = (await http.get("https://api.themoviedb.org/4/list/$id$defaultArguments", headers: {
    'Content-Type': 'application/json;charset=utf-8'
    })).body;

    ContentListModel listModel = ContentListModel.fromJSON(Convert.jsonDecode(rawContentResponse));
    if(!listModel.fullyLoaded && loadFully){
      List<ContentModel> fullContentList = new List();

      // (TMDB starts at index of 1 *sigh*)
      for(int i = 1; i < listModel.totalPages; i++){
        // Make a request to TMDB for the desired page.
        var sublistContentResponse = (await http.get("https://api.themoviedb.org/4/list/$id$defaultArguments&page=$i", headers: {
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

  static Future<ContentModel> getContentInfo(ContentType type, String id) async {
    if(type == ContentType.MOVIE){

      // Get the data from the server.
      http.Response response = await http.get(
          "${TMDB.ROOT_URL}/movie/$id${TMDB.defaultArguments}"
      );
      String json = response.body;

      // Return movie content model.
      return MovieContentModel.fromJSON(
          Convert.jsonDecode(json)
      );

    }else if(type == ContentType.TV_SHOW){

      // Get the data from the server.
      http.Response response = await http.get(
          "${TMDB.ROOT_URL}/tv/$id${TMDB.defaultArguments}"
      );
      String json = response.body;

      // Return TV show content model.
      return TVShowContentModel.fromJSON(
          Convert.jsonDecode(json)
      );

    }

    throw new Exception("Invalid content type: $type");
  }

}