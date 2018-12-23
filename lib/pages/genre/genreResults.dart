import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/res/BottomGradient.dart';


class GenreView extends StatefulWidget{
  final int id;
  final String contentType, genreName;

  GenreView(
      {Key key, @required this.id, @required this.contentType,
        @required this.genreName}) : super(key: key);

  @override
  _GenreViewState createState() => new _GenreViewState();
}

class _GenreViewState extends State<GenreView>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  //TODO: Write future to get data from the api

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar( title: Text(widget.genreName), actions: <Widget>[
        //TODO: Add sorting functionality
      ],),
      body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.76
          ),
          itemBuilder: (BuildContext context, int index){
            //TODO: Write Griview Code
          }
      ),
    );
  }
}

class DiscoverModel {

  final String name, poster_path, backdrop_path;
  final int id, vote_average, vote_count;

  DiscoverModel.fromJSON(Map json)
    : name = json["original_name"] == null ? json["original_title"] : json["original_name"],
        poster_path = json["poster_path"],
        backdrop_path = json["backdrop_path"],
        id = json["id"],
        vote_average = json["vote_average"],
        vote_count = json["vote_count"];
}