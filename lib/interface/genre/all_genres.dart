import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'dart:async';
import 'package:kamino/models/content.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/interface/content/overview.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:kamino/util/genre_names.dart' as genreNames;
import 'package:kamino/util/genre_names.dart' as genre;
import 'package:kamino/partials/content_poster.dart';
import 'package:kamino/partials/result_card.dart';
import 'package:kamino/ui/ui_utils.dart';
import 'package:kamino/interface/genre/genreResults.dart';
import 'package:kamino/util/settings.dart';


class AllGenres extends StatefulWidget{
  final String contentType;

  AllGenres(
      {Key key, @required this.contentType}) : super(key: key);

  @override
  _AllGenresState createState() => new _AllGenresState();
}

class _AllGenresState extends State<AllGenres>{

  int _currentPages = 1;
  ScrollController controller;

  List<DiscoverModel> _results = [];
  List<int> _favIDs = [];
  bool _expandedSearchPref = false;
  List<DropdownMenuItem<int>> _dropDownMenuGenreItems = [];

  String _selectedParam = "popularity.desc";
  int total_pages = 1;
  int _genreID;

  List<DropdownMenuItem<int>> _getDropDownMenuGenreItems() {

    List<DropdownMenuItem<int>> items = [];

    if (widget.contentType == "tv"){
      for(int x = 0; x < genreNames.tv_genres["genres"].length; x++){
        items.add(
            new DropdownMenuItem(
              child: TitleText(genreNames.tv_genres["genres"][x]["name"]),
              value: genreNames.tv_genres["genres"][x]["id"],
            ),
        );
      }
    } else if (widget.contentType == "movie") {
      for(int x = 0; x < genreNames.movie_genres["genres"].length; x++){
        items.add(
          new DropdownMenuItem(
            child: TitleText(genreNames.movie_genres["genres"][x]["name"]),
            value: genreNames.movie_genres["genres"][x]["id"],
          ),
        );
      }
    }

    return items;
  }

  @override
  void initState() {


    setState(() {
      _dropDownMenuGenreItems = _getDropDownMenuGenreItems();
    });


    if (widget.contentType == "tv"){

      //defaults the first page to Action & Adventure for tv shows
      _genreID = 10759;

    } else if (widget.contentType == "movie") {

      //defaults the first page to Action for movies
      _genreID = 28;

    }

    (Settings.detailedContentInfoEnabled as Future).then((data) => setState(() => _expandedSearchPref = data));

    controller = new ScrollController()..addListener(_scrollListener);

    String _contentType = widget.contentType;
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

    String url = "${TMDB.ROOT_URL}/discover/$_contentType"
        "${TMDB.defaultArguments}&"
        "sort_by=$_selectedParam&include_adult=false"
        "&include_video=false&"
        "page=${_currentPages.toString()}&with_genres=$_genreID";

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

  void changedDropDownItem(int selectedGenre) {
    print("you selected $selectedGenre");

    //check the selected id to prevent needless api calls
    if(_genreID != selectedGenre){

      _genreID = selectedGenre;

      _getContent(widget.contentType, selectedGenre).then((data){

        setState(() {
          controller.jumpTo(controller.position.minScrollExtent);
          _results.clear();
          _results = data;
        });

      });
    }
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
                      contentType: ContentType.TV_SHOW )
          )
      );
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ContentOverview(
                      contentId: _results[index].id,
                      contentType: ContentType.MOVIE )
          )
      );
    }
  }

  _applyNewParam(String choice) {

    if (choice != _selectedParam){

      _selectedParam = choice;

      _getContent(widget.contentType, _genreID.toString()).then((data){
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
        title: null,
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 5.0,
        actions: <Widget>[

          new DropdownButton<int>(
            value: _genreID,
            items: _dropDownMenuGenreItems,
            onChanged: changedDropDownItem,
          ),

          generateSearchIcon(context),

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
            onLongPress: (){
              addFavoritePrompt(
                  context, _results[index].name, _results[index].id,
                  TMDB.IMAGE_CDN + _results[index].poster_path,
                  _results[index].year, _results[index].mediaType);
            },
            splashColor: Colors.white,
            child: ContentPoster(
              background: _results[index].poster_path,
              name: _results[index].name,
              releaseDate: _results[index].year,
              mediaType: _results[index].mediaType,
              isFav: _favIDs.contains(_results[index].id),
              hideIcon: true,
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
          onLongPress: (){
            addFavoritePrompt(
                context, _results[index].name, _results[index].id,
                TMDB.IMAGE_CDN + _results[index].poster_path,
                _results[index].year, _results[index].mediaType);
          },
          splashColor: Colors.white,
          child: ResultCard(
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
          S.of(context).no_results_found,
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

        _getContent(widget.contentType, _genreID).then((data){

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
