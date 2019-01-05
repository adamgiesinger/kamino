import 'dart:async';
import 'dart:convert';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/genre_names.dart' as genre;
import 'package:kamino/pages/smart_search/search_results.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kamino/util/ui_constants.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/view/settings/settings_prefs.dart' as settingsPref;
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/partials/poster_card.dart';
import 'package:kamino/partials/poster.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:kamino/view/content/overview.dart';

class ExpandedCard extends StatefulWidget{
  final String url, mediaType;
  final String title;

  ExpandedCard({Key key, @required this.url, @required this.title, @required this.mediaType}) : super(key: key);

  @override
  _ExpandedCardState createState() => new _ExpandedCardState();

}

class _ExpandedCardState extends State<ExpandedCard> {

  ScrollController controller;
  ScrollController controllerList;

  final _pageController = PageController(initialPage: 1);

  int _currentPages;
  int total_pages = 1;
  bool _expandedSearchPref = false;

  List<SearchModel> _results = [];
  List<int> _favIDs = [];

  Future<List<SearchModel>> _getContent(String url, int pageNumber) async {

    List<SearchModel> _data = [];
    Map _temp;

    http.Response _res = await http.get(url);
    _temp = jsonDecode(_res.body);

    if (_temp["results"] != null) {
      total_pages = _temp["total_pages"];
      int resultsCount = _temp["results"].length;

      for(int x = 0; x < resultsCount; x++) {
        _data.add(SearchModel.fromJSON(
            _temp["results"][x], total_pages));
      }
    }

    return _data;
  }

  _openContentScreen(BuildContext context, int index) {

    if (widget.mediaType == "tv") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ContentOverview(
                      contentId: _results[index].id,
                      contentType: ContentOverviewContentType.TV_SHOW )
          )
      );
    } else if (widget.mediaType == "movie"){
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

  @override
  void initState() {

    _currentPages = 1;

    settingsPref.getBoolPref("expandedSearch").then((data){
      setState(() {
        _expandedSearchPref = data;
      });
    });

    controller = new ScrollController()..addListener(_scrollListener);
    controllerList = new ScrollController()..addListener(_scrollListenerList);

    databaseHelper.getAllFavIDs().then((data){

      _favIDs = data;
    });

    _getContent(widget.url.replaceAll("page=1", "page=$_currentPages"), _currentPages).then((data){

      setState(() {
        _results = data;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: Scaffold(
        appBar: AppBar(
          title: TitleText(widget.title),
          centerTitle: true,
          backgroundColor: Theme.of(context).cardColor,
          actions: <Widget>[
            searchIconButton(context),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {

            await Future.delayed(Duration(seconds: 2));

            //refresh the favourites data
            databaseHelper.getAllFavIDs().then((data){

              _favIDs.clear();
              setState(() {
                _favIDs = data;
              });
            });
          },
          child: _expandedSearchPref == false ? _gridPage() : _listPage(),
        ),
      ),
    );
  }

  Widget _listPage(){
    return ListView.builder(
      itemCount: _results.length,
      controller: controllerList,
      itemBuilder: (BuildContext context, int index){
        return InkWell(
          onTap: () => _openContentScreen(context, index),
          onLongPress: (){
            saveFavPopUpDialog(
                context, _results[index].name, _results[index].id,
                image_cdn + _results[index].poster_path,
                _results[index].year, _results[index].mediaType);
          },
          splashColor: Colors.white,
          child: Padding(
            padding: index == 0 ?
            EdgeInsets.only(top: 5.0) : EdgeInsets.only(top: 0.0),
            child: PosterCard(
              background: _results[index].poster_path,
              name: _results[index].name,
              genre: genre.getGenreNames(_results[index].genre_ids,_results[index].mediaType),
              mediaType: _results[index].mediaType,
              ratings: _results[index].vote_average,
              overview: _results[index].overview,
              isFav: _favIDs.contains(_results[index].id),
              elevation: 5.0,
            ),
          ),
        );
      },
    );
  }

  Widget _gridPage(){
    return GridView.builder(
        controller: controller,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.76
        ),

        itemCount: _results.length,

        itemBuilder: (BuildContext context, int index){
          return InkWell(
            onTap: () => _openContentScreen(context, index),
            onLongPress: (){
              saveFavPopUpDialog(
                  context, _results[index].name, _results[index].id,
                  image_cdn + _results[index].poster_path,
                  _results[index].year, _results[index].mediaType);
            },
            splashColor: Colors.white,
            child: Padding(
              padding: [0, 1, 2].contains(index) ?
              EdgeInsets.only(top: 5.0) : EdgeInsets.only(top: 0.0),
              child: Poster(
                background: _results[index].poster_path,
                name: _results[index].name,
                releaseDate: _results[index].year,
                mediaType: _results[index].mediaType,
                isFav: _favIDs.contains(_results[index].id),
              ),
            ),
          );
        }
    );
  }

  void _scrollListener(){

    if (controller.offset >= controller.position.extentAfter) {

      //check that you haven't already loaded the last page
      if (_currentPages < total_pages){

        //load the next page
        _currentPages = _currentPages + 1;

        _getContent(widget.url.replaceAll("page=1", "page=$_currentPages"), _currentPages).then((data){

          setState(() {
            _results = _results + data;
          });

        });
      }
    }
  }
  void _scrollListenerList(){

    if (controllerList.offset >= controllerList.position.extentAfter) {

      //check that you haven't already loaded the last page
      if (_currentPages < total_pages){

        //load the next page
        _currentPages = _currentPages + 1;

        _getContent(widget.url.replaceAll("page=1", "page=$_currentPages"), _currentPages).then((data){

          setState(() {
            _results = _results + data;
          });

        });
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.removeListener(_scrollListener);
    controllerList.removeListener(_scrollListenerList);
    super.dispose();
  }


}
