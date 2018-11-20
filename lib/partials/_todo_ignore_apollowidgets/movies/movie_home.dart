import 'package:flutter/material.dart';
import 'now_playing.dart';
import 'popular_movie.dart';
import 'top_rated_movie.dart';
import 'upcoming_movies.dart';


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