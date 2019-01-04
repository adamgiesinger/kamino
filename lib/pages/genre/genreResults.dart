import 'package:flutter/material.dart';
import 'dart:async';
import 'package:kamino/models/content.dart';
import 'package:kamino/view/content/overview.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/view/settings/settings_prefs.dart' as settingsPref;
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:kamino/util/genre_names.dart' as genreNames;
import 'package:kamino/util/genre_names.dart' as genre;
import 'package:kamino/partials/poster.dart';
import 'package:kamino/partials/poster_card.dart';
import 'package:kamino/pages/smart_search/search_results.dart';
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

  int _currentPages = 1;
  ScrollController controller;

  List<DiscoverModel> _results = [];
  List<int> _favIDs = [];
  bool _expandedSearchPref = false;

  String _selectedParam = "popularity.desc";
  int total_pages = 1;

  @override
  void initState() {

    settingsPref.getBoolPref("expandedSearch").then((data){
      setState(() {
        _expandedSearchPref = data;
      });
    });

    controller = new ScrollController()..addListener(_scrollListener);

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
        "&include_video=false&"
        "page=${_currentPages.toString()}&with_genres=$_genreID";

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

  _applyNewParam(String choice) {

    if (choice != _selectedParam){

      _selectedParam = choice;

      _getContent(widget.contentType, widget.genreID.toString()).then((data){
        setState(() {

          //clear grid-view and replenish with new data
          _results.clear();
          _results = data;

          //scroll to the top of the results
          controller.jumpTo(controller.position.minScrollExtent);
        });
        _currentPages = 1;
      });
    }
    Navigator.of(context).pop;
  }

  @override
  Widget build(BuildContext context) {

    TextStyle _glacialFont = TextStyle(
        fontFamily: "GlacialIndifference");

    return Scaffold(
      appBar: new AppBar(
        title: Text(widget.genreName, style: _glacialFont,),
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 5.0,
        actions: <Widget>[
        //Add sorting functionality
          IconButton(
              icon: Icon(Icons.sort), onPressed: (){
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_){
                return GenreSortDialog(
                  onValueChange: _applyNewParam,
                  selectedParam: _selectedParam,
                );
              }
            );
          }),
      ],
      ),
      body: Scrollbar(
        child: _expandedSearchPref == false ? _gridResults() : _listResult(),
      ),
    );
  }

  Widget _gridResults(){
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
    );
  }

  Widget _listResult(){
    return ListView.builder(
      itemCount: _results.length,
      controller: controller,

      itemBuilder: (BuildContext context, int index){
        return InkWell(
          onTap: () => _openContentScreen(context, index),
          splashColor: Colors.white,
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
        );
      },
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

  void _scrollListener() {
    print(controller.position.extentAfter);

    if (controller.offset >= controller.position.maxScrollExtent) {

      //check that you haven't already loaded the last page
      if (_currentPages < total_pages){

        //load the next page
        _currentPages = _currentPages + 1;

        _getContent(widget.contentType, widget.genreID).then((data){

          setState(() {
            _results = _results + data;
          });

        });
      }
    }
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }
}

class GenreSortDialog extends StatefulWidget {
  final String selectedParam;
  final void Function(String) onValueChange;

  GenreSortDialog(
      {Key key, @required this.selectedParam, this.onValueChange}) :
        super(key: key);

  @override
  _GenreSortDialogState createState() => new _GenreSortDialogState();
}

class _GenreSortDialogState extends State<GenreSortDialog> {

  String _sortByValue;
  String _orderValue;

  @override
  void initState() {
    super.initState();
    var temp = widget.selectedParam.split(".");
    _sortByValue = temp[0];
    _orderValue = "."+temp[1];
  }


  TextStyle _glacialStyle = TextStyle(
    fontFamily: "GlacialIndifference",
    //fontSize: 19.0,
  );

  TextStyle _glacialStyle1 = TextStyle(
    fontFamily: "GlacialIndifference",
    fontSize: 17.0,
  );

  Widget build(BuildContext context){
    return new SimpleDialog(
      title: Text("Sort by",
        style: _glacialStyle,
      ),
      children: <Widget>[
        //Title(title: "Sort by", color: Colors.white,),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: Divider( color: Colors.white,),
        ),
        RadioListTile(
          value: "popularity",
          title: Text("Popularity", style: _glacialStyle1,),
          groupValue: _sortByValue,
          onChanged: _onSortChange,
        ),
        RadioListTile(
          value: "first_air_date",
          title: Text("Air date", style: _glacialStyle1,),
          groupValue: _sortByValue,
          onChanged: _onSortChange,
        ),
        RadioListTile(
          value: "vote_average",
          title: Text("Vote Average", style: _glacialStyle1,),
          groupValue: _sortByValue,
          onChanged: _onSortChange,
        ),

        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  top: 7.0, bottom: 7.0, left: 32.0),
              child: Text("ORDER", style:_glacialStyle1),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right:11.0),
              child: Divider(color: Colors.white,),
            ),
          ],
        ),

        RadioListTile(
          value: ".asc",
          title: Text("Ascending", style: _glacialStyle1,),
          groupValue: _orderValue,
          onChanged: _onOrderChange,
        ),
        RadioListTile(
          value: ".desc",
          title: Text("Descending", style: _glacialStyle1,),
          groupValue: _orderValue,
          onChanged: _onOrderChange,
        ),

        Padding(
          padding: const EdgeInsets.only(left: 55.0),
          child: Row(
            children: <Widget>[
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Cancel",
                  style: _glacialStyle1,
                ),
              ),
              FlatButton(
                onPressed: (){
                  widget.onValueChange(_sortByValue+_orderValue);
                  Navigator.pop(context);
                },
                child: Text("Sort", style: _glacialStyle1,),
              ),
            ],),
        )
      ],
    );
  }

  void _onOrderChange(String value) {
    setState(() {
      _orderValue = value;
    });
  }

  void _onSortChange(String value){
    setState(() {
      _sortByValue = value;
    });
  }

}

class DiscoverModel {

  final String name, poster_path, backdrop_path, year, mediaType, overview;
  final int id, vote_count, page;
  final List genre_ids;
  final int vote_average;

  DiscoverModel.fromJSON(Map json, int pageCount, String contentType)
      : name = json["name"] == null ? json["title"] : json["name"],
        poster_path = json["poster_path"],
        backdrop_path = json["backdrop_path"],
        id = json["id"],
        vote_average = json["vote_average"] != null ? (json["vote_average"]).round() : 0,
        overview = json["overview"],
        genre_ids = json["genre_ids"],
        mediaType = contentType,
        page = pageCount,
        year = json["first_air_date"] == null ?
        json["release_date"] : json["first_air_date"],
        vote_count = json["vote_count"];
}