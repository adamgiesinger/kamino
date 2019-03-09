import 'dart:convert' as Convert;

import 'package:http/http.dart' as http;
import 'package:kamino/models/content.dart';
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

  static Future<List<ContentModel>> getList(String id) async {
    var rawContentResponse = (await http.get("https://api.themoviedb.org/4/list/$id$defaultArguments", headers: {
      'Content-Type': 'application/json;charset=utf-8'
    })).body;

    var content = Convert.jsonDecode(rawContentResponse);
    List<dynamic> rawContentList = content["results"];

    List<ContentModel> contentList = rawContentList.map((contentItem) => contentItem['media_type'] == 'movie'
        ? MovieContentModel.fromJSON(contentItem)
        : TVShowContentModel.fromJSON(contentItem)
    ).toList();

    return contentList;
  }

}