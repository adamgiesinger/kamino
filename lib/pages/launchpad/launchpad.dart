import 'package:flutter/material.dart';
import 'package:kamino/partials/apollowidgets/_widget.dart';
import 'dart:async';
import 'package:kamino/models/content.dart';
import 'package:kamino/view/content/overview.dart';
import 'package:kamino/pages/smart_search/search_results.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/view/settings/settings_prefs.dart' as settingsPref;
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:kamino/util/genre_names.dart' as genreNames;
import 'package:kamino/util/genre_names.dart' as genre;
import 'package:kamino/partials/poster.dart';
import 'package:kamino/partials/poster_card.dart';

class MyLaunchPad extends StatelessWidget{

  final List<String> launchOptions;
  final List<int> favIDs;

  MyLaunchPad({Key key, @required this.launchOptions, @required this.favIDs});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemCount: launchOptions.length,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index){
        return SizedBox(
          height: 666.0,
          child: LaunchCard(
            title: launchOptions[index],
            favState: favIDs,
          ),
        );
      },
    );
  }
}

class LaunchCard extends StatefulWidget {

  LaunchCard({Key key, @required this.title, @required this.favState}) : super();
  final String title;
  final List<int> favState;

  @override
  _LaunchCardState createState() => new _LaunchCardState();
}

class _LaunchCardState extends State<LaunchCard> {



  List<String> _urlBuilder(){

    String _header = "";
    String _mediaType = "";
    String _tv = "tv";
    String _movie = "movie";

    if (widget.title == "Airing Today"){
      _header = "Airing Today";
      _mediaType = _tv;

    }else if (widget.title == "On The Air"){
      _header = "On The Air";
      _mediaType = _tv;

    }else if (widget.title == "Popular TV Shows"){
      _header = "Popular";
      _mediaType = _tv;

    }else if (widget.title == "Top Rated TV Shows"){
      _header = "Top Rated";
      _mediaType = _tv;

    }else if (widget.title == "Now Playing"){
      _header = "Now Playing";
      _mediaType = _movie;

    }else if (widget.title == "Popular Movies"){
      _header = "Popular";
      _mediaType = _movie;

    }else if (widget.title == "Top Rated Movies"){
      _header = "Top Rated";
      _mediaType = _movie;

    }else if (widget.title == "Upcoming Movies"){
      _header = "Upcoming";
      _mediaType = _movie;

    }

    //formatting the string to comply with the tmdb api docs

    print("header si... $_header");
    print("header si... $_mediaType");

    String _baseUrl = "${tmdb.root_url}/$_mediaType/${_header.replaceAll(" ", "_").toLowerCase()}${tmdb.defaultArguments}&page=1";

    return [_baseUrl, _mediaType, _header];
  }

  EdgeInsets _titlePaddingBuilder(){

    EdgeInsets _titlePadding = EdgeInsets.only(left: 5.0, right: 5.0);

    if (widget.title == "Airing Today"){

    }else if (widget.title == "On The Air"){

    }else if (widget.title == "Popular TV Shows"){

    }else if (widget.title == "Top Rated TV Shows"){

    }else if (widget.title == "Now Playing"){

    }else if (widget.title == "Popular Movies"){

    }else if (widget.title == "Top Rated Movies"){

    }else if (widget.title == "Upcoming Movies"){

    }

    return _titlePadding;
  }

  Future<List<SearchModel>> _getDiscoverData() async {

    List<SearchModel> _data = [];
    Map _temp;

    print("url is... ${_urlBuilder()}");

    http.Response _res = await http.get(_urlBuilder()[0]);
    _temp = jsonDecode(_res.body);

    if (_temp["results"] != null) {
      int total_pages = _temp["total_pages"];
      int resultsCount = _temp["results"].length;

      for(int x = 0; x < resultsCount; x++) {
        _data.add(SearchModel.fromJSON(
            _temp["results"][x], total_pages));
      }
    }

    return _data;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        elevation: 5.0,
        color: Theme.of(context).cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: _titlePaddingBuilder(),
                  child: Text(widget.title),
                ),
                FlatButton(onPressed: null, child: Text("See All"))
              ],
            ),

            SizedBox(
                child: _posterListView(context),
              height: 752.0,
              width: 330.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _posterListView(BuildContext context){

    return FutureBuilder<List<SearchModel>>(
        future: _getDiscoverData(), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<List<SearchModel>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Container();
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));

              if (snapshot.hasData){
                print(snapshot.data[0].poster_path);
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  //scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index){

                    print("found the following image links ${snapshot.data[index].poster_path}");

                    return SizedBox(
                      height: 752.0,
                      width: 120.0,
                      child: Container(
                        child: Poster(
                            background: snapshot.data[index].poster_path,
                            name: snapshot.data[index].name,
                            releaseDate: snapshot.data[index].year,
                            mediaType: snapshot.data[index].mediaType,
                            isFav: widget.favState.contains(snapshot.data[index].id)
                        ),
                      ),
                    );
                  },
                );
              }
          }
          return null; // unreachable
        },
    );
  }

}