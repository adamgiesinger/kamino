import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/pages/smart_search/search_results.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;


class SmartSearch extends SearchDelegate<String>{

  Future<List<String>> _fetchSearchList(String criteria) async {

    List<String> _data = [];

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

        //print(element["name"].toString().substring(0, criteria.length).toLowerCase()== criteria.toLowerCase());

        if (element["media_type"] != "person"){

          String name = element["name"] == null ? element["title"] : element["name"];
          _data.add(name);
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

    return SearchResult(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context){

    return FutureBuilder<List<String>>(
      future: query.isEmpty ?
      databaseHelper.getSearchHistory() : _fetchSearchList(query), // a previously-obtained Future<String> or null
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
            //return Text('Result: ${snapshot.data}');
        }
        return null; // unreachable
      }
    );
  }


}
