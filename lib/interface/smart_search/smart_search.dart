import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/interface/smart_search/search_results.dart';
import 'package:kamino/interface/content/overview.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/util/genre_names.dart' as genre;
import 'package:kamino/partials/result_card.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/util/settings.dart';

class SmartSearch extends SearchDelegate<String> {

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  bool _expandedSearchPref = false;

  SmartSearch() {
    (Settings.detailedContentInfoEnabled as Future).then((data) => _expandedSearchPref = data);
  }

  Future<List<SearchModel>> _fetchSearchList(BuildContext context, String criteria) async {

    Future.delayed(new Duration(milliseconds: 500));

    List<SearchModel> _data = [];

    String url = "${TMDB.ROOT_URL}/search/"
        "multi${TMDB.getDefaultArguments(context)}&"
        "query=$criteria&page=1&include_adult=false";

    http.Response res = await http.get(url);

    Map results = jsonDecode(res.body);
    //List<Map> _resultsList = [];

    var _resultsList = results["results"];

    if (_resultsList != null) {
      _resultsList.forEach((var element) {
        if (element["media_type"] != "person") {
          String name =
              element["name"] == null ? element["title"] : element["name"];
          _data.add(new SearchModel.fromJSON(element, 1));
        }
      });
    }
    return _data;
  }

  List<String> searchHistory = [];

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      primaryColor: Theme.of(context).backgroundColor,
      textTheme: TextTheme(
        title: TextStyle(
          fontFamily: "GlacialIndifference",
          fontSize: 19.0,
          color: Theme.of(context).textTheme.body1.color
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for search bar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon on the left of appbar
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if(query == null || query.isEmpty) return Container();

    _saveToSearchHistory(query);
    _promoteQuerySearchHistory(query);
    return SearchResultView(query: query);
  }

  Widget _searchHistoryListView(AsyncSnapshot snapshot) {
    return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              showResults(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: InkWell(
                onTap: () {
                  query = snapshot.data[index].toString();
                  showResults(context);
                },
                child: ListTile(
                  leading: Icon(Icons.history),
                  title: RichText(
                    text: TextSpan(
                      text: snapshot.data[index],
                      style: TextStyle(
                          fontFamily: ("GlacialIndifference"),
                          fontSize: 19.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _suggestionsPosterCard(AsyncSnapshot snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(top: 5.0, left: 3.0, right: 3.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ContentOverview(
                          contentId: snapshot.data[index].id,
                          contentType: snapshot.data[index].mediaType == "tv"
                              ? ContentType.TV_SHOW
                              : ContentType.MOVIE)));
            },
            child: ResultCard(
              isFav: false,
              background: snapshot.data[index].poster_path,
              name: snapshot.data[index].title,
              overview: snapshot.data[index].overview,
              ratings: snapshot.data[index].vote_average,
              elevation: 0.0,
              mediaType: snapshot.data[index].mediaType,
              genre: genre.getGenreNames(snapshot.data[index].genre_ids,
                  snapshot.data[index].mediaType),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchHistory() {
    return FutureBuilder(
      future: _memoizer.runOnce(() async => await Settings.searchHistory), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Container();
            /*return Center(child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor
              ),
            ));*/
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return _searchHistoryListView(snapshot);
            }
          //return Text('Result: ${snapshot.data}');
        }
        return null; // unreachable
      }
    );
  }

  Widget _simplifiedSuggestions(AsyncSnapshot snapshot) {
    return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ContentOverview(
                          contentId: snapshot.data[index].id,
                          contentType: snapshot.data[index].mediaType == "tv"
                              ? ContentType.TV_SHOW
                              : ContentType.MOVIE)));
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
              child: ListTile(
                leading: snapshot.data[index].mediaType == "tv"
                    ? Icon(Icons.live_tv)
                    : Icon(Icons.local_movies),
                title: RichText(
                  text: TextSpan(
                    text: _suggestionName(snapshot, index),
                    style: TextStyle(
                        fontFamily: ("GlacialIndifference"),
                        fontSize: 19.0,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).primaryTextTheme.body1.color),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        });
  }

  String _suggestionName(AsyncSnapshot snapshot, int index){
    if (snapshot.data[index].year != null && snapshot.data[index].year.length > 3){
      return "${snapshot.data[index].name} (${snapshot.data[index].year.toString().substring(0,4)})";
    }

    return snapshot.data[index].name;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isEmpty
        ? _buildSearchHistory()
        : FutureBuilder<List<SearchModel>>(
            future: _fetchSearchList(context, query), // a previously-obtained Future<String> or null
            builder: (BuildContext context,
                AsyncSnapshot<List<SearchModel>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:

                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Container();
                  // This is just for suggestions.
                  /*return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor
                      ),
                    ));*/
                case ConnectionState.done:
                  if (snapshot.hasError) {

                      if(snapshot.error is SocketException
                          || snapshot.error is HttpException) return OfflineMixin();

                      return ErrorLoadingMixin(errorMessage: "Well this is awkward... An error occurred whilst loading search results.");

                  } else if (snapshot.hasData) {
                    return _simplifiedSuggestions(snapshot);
                  }
                //return Text('Result: ${snapshot.data}');
              }
              return null; // unreachable
            });
  }

  Future<void> _removeSearchItem(String value) async{
    List<String> _searchHistory = ((await (Settings.searchHistory)) as List);
    _searchHistory.remove(value);
    await (Settings.searchHistory = _searchHistory);
  }

  Future<void> _saveToSearchHistory(String value) async {
    if (value != null && value.isNotEmpty) {

      // Load the stored search history.
      List<String> _storedSearchHistory = await (Settings.searchHistory);

      // Cancel if the stored search history already contains this element.
      if(_storedSearchHistory.contains(value)) return;

      // Prepend the new search history entry to the old search history.
      List<String> _searchHistory = [value] + _storedSearchHistory;

      // Cap the search history length at 40 by removing any trailing history items.
      while(_searchHistory.length > 40) _searchHistory.remove(_searchHistory.last);

      // Save the new search history list.
      await (Settings.searchHistory = _searchHistory);
    }
  }

  ///
  /// Ensures the most recent search query remains at the top
  /// of the search history.
  ///
  Future<void> _promoteQuerySearchHistory(String value) async {
    List<String> searches = (await (Settings.searchHistory)).cast<String>();

    // Ensure duplicates are removed.
    searches = searches.toSet().toList();

    // Remove current query from searches and re-add query at top of searches list.
    searches.remove(value);
    searches = [value] + searches;

    await (Settings.searchHistory = searches);
  }

}
