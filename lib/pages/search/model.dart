import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:kamino/vendor/config/official.dart' as api;

class SearchResult {
  final String mediaType;
  final int id, pageCount;
  final String title, posterPath,backdropPath, year;

  SearchResult(this.mediaType, this.id, this.title,
      this.posterPath, this.backdropPath, this.year, this.pageCount);

  String get tv => mediaType;
  String get checkPoster => posterPath;
  int get showID => id;

  SearchResult.fromJson(Map json)
      : mediaType = json["media_type"], id = json["id"],
        title = json["original_name"] != null ?
        json["original_name"]: json["original_title"],
        pageCount = json["total_pages"],
        posterPath = json["poster_path"],
        backdropPath = json["backdrop_path"],
        year = json["release_date"] == null ?
        json["first_air_date"] :  json["release_date"];
}

class API {
  final http.Client _client = http.Client();

  static const String _url =
      "${api.tvdb_root_url}/search/multi${api.tvdb_default_arguments}" +
      "&include_adult=false&query=";

  Future<List<SearchResult>>  get(String query) async {
    List<SearchResult> list = [];

    await _client
        .get(Uri.parse(_url + query))
        .catchError((error){
          print("An error occurred: " + error);
        })
        .then((res) => res.body)
        .then(jsonDecode)
        .then((json) => json["results"])
        .then((movies) => movies.forEach((movie) => list.add(SearchResult.fromJson(movie))));

    list.removeWhere((item) => item.mediaType != "movie" && item.mediaType != "tv");
    list.removeWhere((item) => item.id == null);

    return list;
  }
}