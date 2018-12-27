import 'package:flutter/material.dart';
import 'dart:async';
import 'package:kamino/models/content.dart';
import 'package:kamino/view/content/overview.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:kamino/partials/poster.dart';
import 'package:kamino/res/BottomGradient.dart';


class GenreView extends StatefulWidget{
  final String contentType, genreName;
  final int genreID;

  GenreView(
      {Key key, @required this.contentType, @required this.genreID,
        @required this.genreName}) : super(key: key);

  @override
  _GenreViewState createState() => new _GenreViewState();
}

class _GenreViewState extends State<GenreView>{

  List<String> _sortParams = [
    "popularity.asc", "popularity.desc", "vote_average.desc",
    "vote_average.asc", "first_air_date.desc", "first_air_date.asc"
  ];

  List<DiscoverModel> _results = [];
  List<int> _favIDs = [];

  String _selectedParam = "popularity.desc";
  int total_pages = 1;

  @override
  void initState() {

    String _contentType = widget.contentType;
    String _genreName = widget.genreName;
    String _genreID = widget.genreID.toString();

    databaseHelper.getAllFavIDs().then((data){

      _favIDs = data;
    });

    _getContent(_contentType, _genreID).then((data){

      setState(() {
        _results = data;
      });

    });

    super.initState();
  }

  //get data from the api
  Future<List<DiscoverModel>> _getContent(_contentType, _genreID) async {

    List<DiscoverModel> _data = [];
    Map _temp;

    String url = "${tmdb.root_url}/discover/$_contentType"
        "${tmdb.defaultArguments}&"
        "sort_by=$_selectedParam&include_adult=false"
        "&include_video=false&page=1&with_genres=$_genreID";

    print("url is... $url");

    http.Response _res = await http.get(url);
    _temp = jsonDecode(_res.body);

    if (_temp["results"] != null) {
      total_pages = _temp["total_pages"];
      int resultsCount = _temp["results"].length;

      for(int x = 0; x < resultsCount; x++) {
        _data.add(DiscoverModel.fromJSON(
            _temp["results"][x], total_pages, _contentType));
      }
    }

    return _data;
  }

  _openContentScreen(BuildContext context, int index) {
    //print("id is ${snapshot.data[index].showID}");

    if (_results[index].mediaType == "tv") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ContentOverview(
                      contentId: _results[index].id,
                      contentType: ContentOverviewContentType.TV_SHOW )
          )
      );
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ContentOverview(
                      contentId: _results[index].id,
                      contentType: ContentOverviewContentType.MOVIE )
          )
      );
    }
  }

  void _applyNewParam(String choice) {

    print("my choice is...$choice");

    if (choice != _selectedParam){

      _selectedParam = choice;
      print("new choice is $_selectedParam");

      _getContent(widget.contentType, widget.genreID.toString()).then((data){
        setState(() {
          _results.clear();
          _results = data;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    TextStyle _glacialFont = TextStyle(
        fontFamily: "GlacialIndifference");

    List<String> _menuOptions = [
      "Popularity Asc", "Popularity Desc", "Vote Average Desc",
      "Vote Average Asc", "First Air Date Desc", "First Air Date Asc"
    ];

    return Scaffold(
      appBar: new AppBar(
        title: Text(widget.genreName, style: _glacialFont,),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 5.0,
        actions: <Widget>[
        //Add sorting functionality
          PopupMenuButton<String>(
            icon: Icon(Icons.sort),
            itemBuilder: (BuildContext context){
              return _sortParams.map((String choice){
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(_menuOptions[_sortParams.indexOf(choice)]),
                );
              }).toList();
            },
            initialValue: _selectedParam,
            onSelected: _applyNewParam,
          )
      ],
      ),
      body: _results.length == 0 ? _nothingFoundScreen() : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.76
          ),

          itemCount: _results.length,

          itemBuilder: (BuildContext context, int index){
            return InkWell(
              onTap: () => _openContentScreen(context, index),
              splashColor: Colors.white,
              child: Poster(
                background: _results[index].poster_path,
                name: _results[index].name,
                releaseDate: _results[index].year,
                mediaType: _results[index].mediaType,
                isFav: _favIDs.contains(_results[index].id),
              ),
            );
          }
      ),
    );
  }

  Widget _nothingFoundScreen() {
    const _paddingWeight = 18.0;

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.only(left: _paddingWeight, right: _paddingWeight),
        child: Text(
          "Can't find anything...",
          maxLines: 3,
          style: TextStyle(
              fontSize: 22.0,
              fontFamily: 'GlacialIndifference',
              color: Theme.of(context).primaryTextTheme.body1.color),
        ),
      ),
    );
  }
}

class DiscoverModel {

  final String name, poster_path, backdrop_path, year, mediaType;
  final int id, vote_count, page;

  DiscoverModel.fromJSON(Map json, int pageCount, String contentType)
    : name = json["original_name"] == null ? json["original_title"] : json["original_name"],
        poster_path = json["poster_path"],
        backdrop_path = json["backdrop_path"],
        id = json["id"],
        mediaType = contentType,
        page = pageCount,
        year = json["first_air_date"] == null ?
        json["release_date"] : json["first_air_date"],
        vote_count = json["vote_count"];
}