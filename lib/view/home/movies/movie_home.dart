import 'package:kamino/api.dart' as api;
import 'package:kamino/ui/uielements.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kamino/res/BottomGradient.dart';
import 'package:kamino/view/home/movies/now_playing.dart';
import 'package:kamino/view/home/movies/popular_movie.dart';
import 'package:kamino/view/home/movies/top_rated_movie.dart';
import 'package:kamino/view/home/movies/upcoming_movies.dart';


const splashColour = Colors.purpleAccent;
const primaryColor = const Color(0xFF8147FF);
const secondaryColor = const Color(0xFF303A47);
const backgroundColor = const Color(0xFF26282C);
const highlightColor = const Color(0x968147FF);

class MovieHome extends StatefulWidget{
  @override
  _MovieHomeState createState() => _MovieHomeState();
}

class _MovieHomeState extends State<MovieHome> with AutomaticKeepAliveClientMixin<MovieHome>{

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: ListView(
        addAutomaticKeepAlives: true,
        children: <Widget>[
          NowPlaying(),
          PopularMovies(),
          TopRatedMovies(),
          UpcomingMovies(),
        ],
      ),
    );
  }

  // TODO: implement wantKeepAlive
  @override
  bool get wantKeepAlive => true;

}