import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/pages/smart_search/search_results.dart';
import 'package:kamino/view/content/overview.dart';
import 'package:kamino/util/genre_names.dart' as genre;
import 'package:kamino/partials/poster_card.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;


class SmartSearch extends SearchDelegate<String>{

  Future<List<SearchModel>> _fetchSearchList(String criteria) async {

    List<SearchModel> _data = [];

    String url = "${tmdb.root_url}/search/"
        "multi${tmdb.defaultArguments}&"
        "query=$criteria&page=1&include_adult=false";

    print(url);
    http.Response res = await http.get(url);

    Map results = jsonDecode(res.body);
    //List<Map> _resultsList = [];

    var _resultsList = results["results"];

    if (_resultsList != null)  {
      //print("resukts lsit is $_resultsList");
      _resultsList.forEach((var element){

        if (element["media_type"] != "person"){

          String name = element["name"] == null ? element["title"] : element["name"];
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
      primaryColor: Theme.of(context).cardColor,
      textTheme: TextTheme(
        title: TextStyle(
            fontFamily: "GlacialIndifference",
            fontSize: 19.0,
            color: Theme.of(context).primaryTextTheme.body1.color
        ),
      ),
      textSelectionColor: Theme.of(context).textSelectionColor,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for search bar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){ query = "";},
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon on the left of appbar
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: (){
        Navigator.of(context).pop();
      },);
  }

  @override
  Widget buildResults(BuildContext context) {

    return new SearchResult(query: query);
  }

  Widget _searchHistoryListView(AsyncSnapshot snapshot) {

    return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: (){
              showResults(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: InkWell(
                onTap: (){
                  query = snapshot.data[index];
                  showResults(context);
                },
                child: ListTile(
                  leading: query.isNotEmpty ? Icon(Icons.search): Icon(Icons.history),
                  title: RichText(
                    text: TextSpan(
                      text:snapshot.data[index],
                      style: TextStyle(
                          fontFamily:("GlacialIndifference"),
                          fontSize: 19.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );
  }

  Widget _suggestionsPosterCard(AsyncSnapshot snapshot) {

    return ListView.builder(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index){

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
                              ? ContentOverviewContentType.TV_SHOW
                              : ContentOverviewContentType.MOVIE)));
            },

            child: PosterCard(
              isFav: false,
              background: snapshot.data[index].poster_path,
              name: snapshot.data[index].name,
              overview: snapshot.data[index].overview,
              ratings: snapshot.data[index].vote_average,
              mediaType: snapshot.data[index].mediaType,
              genre: genre.getGenreNames(snapshot.data[index].genre_ids, snapshot.data[index].mediaType),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchHistory(){
    return FutureBuilder<List<String>>(
        future: databaseHelper.getSearchHistory(), // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Container();
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
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

  @override
  Widget buildSuggestions(BuildContext context){

    return query.isEmpty ? _buildSearchHistory():
    FutureBuilder<List<SearchModel>>(
      future: _fetchSearchList(query), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<SearchModel>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Container();
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator(backgroundColor: Colors.white,));
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return query.isEmpty ? _searchHistoryListView(snapshot) :
              _suggestionsPosterCard(snapshot);
            }
            //return Text('Result: ${snapshot.data}');
        }
        return null; // unreachable
      }
    );
  }


}
