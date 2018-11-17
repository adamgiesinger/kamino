import 'package:kamino/vendor/config/official.dart' as api;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';


const splashColour = Colors.purpleAccent;
const primaryColor = const Color(0xFF8147FF);
const secondaryColor = const Color(0xFF303A47);
const backgroundColor = const Color(0xFF26282C);
const highlightColor = const Color(0x968147FF);

class ExpandedView extends StatelessWidget{

  //data passed from previous screen when user presses the see all button
  int id, resultsPages;
  String screen;

  ExpandedView(int id, String screen, int resultsPages){
    this.id = id;
    this.resultsPages = resultsPages;
    this.screen = screen;
  }

  String apiSelector(){
    String _output;

    if (screen == "Airing Today"){
      _output = "airing_today";

    } else if (screen == "Top Rated"){
      _output = "top_rated";

    } else if (screen == "Popular Shows"){
      _output = "popular";

    } else if (screen == "On The Air"){
      _output = "on_the_air";

    }
    return _output;
  }

  Future<List<ExpandedTVModel>> getMoreResults() async{

    List<ExpandedTVModel> _data = new List<ExpandedTVModel>();

    String url = "https://api.themoviedb.org/3/tv/${apiSelector()}?"
        "api_key=${api.tvdb_api_key}&language=en-US&page=";

    final http.Client _client = http.Client();

    await _client
        .get(url)
        .then((res) => res.body)
        .then(jsonDecode)
        .then((json) => json["results"])
        .then((tvShows) => tvShows.forEach((tv) => _data.add(ExpandedTVModel.fromJSON(tv))));

    return _data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text(screen),
        centerTitle: true,
        elevation: 5.0,
        backgroundColor: backgroundColor,
      ),
      body: _tvShowsGridView(context),
    );
  }

  Widget _tvShowsGridView(BuildContext context){
    return FutureBuilder(
      future: null,
      builder: null,
    );
  }
}

class ExpandedTVModel{

  final int id;
  final String first_air_date, poster_path, backdrop_path;
  final String name;
  final double popularity;

  ExpandedTVModel.fromJSON(Map json)
      : id = json["id"],
        first_air_date = json["first_air_date"],
        poster_path = json["poster_path"],
        backdrop_path = json["backdrop_path"],
        name = json["original_name"] == null ?
        json["name"] : json["original_name"],
        popularity = json["popularity"];
}