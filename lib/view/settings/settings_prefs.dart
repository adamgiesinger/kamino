import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


//IMPORTANT TRAKT CRED INFO
/*
   key - traktCredentials
   0 - access token
   1 - refresh token
   2 - expiry date
*/





Future<bool> saveBoolPref(String name, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(name, value);
  return value;
}

List<String> launchpadOptions() => _movieOptions + _tvOptions;

const List<String> _tvOptions = ["Airing Today","On The Air","Popular TV Shows","Top Rated TV Shows"];

const List<String> _movieOptions = ["Now Playing","Popular Movies","Top Rated Movies","Upcoming Movies"];

Future<bool> getBoolPref(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(name) == null ? false : prefs.getBool(name);
}

Future<List<String>> getListPref(String name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(name) == null ?
  launchpadOptions() : prefs.getStringList(name);
}

Future<Null> saveListPref(String name, List<String> value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList(name, value);
}

Future<List<String>> getSearchHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  //print("retrieved this array from shared pref: ${prefs.getStringList("searchHistory")}");

  if (prefs.getStringList("searchHistory") == null){

    return [];
  }

  //remove duplicates from the results
  List<String> _searches = prefs.getStringList("searchHistory");
  List<String> _temp = [];

  _searches.forEach((String element){

    if (!_temp.contains(element)){
      _temp.add(element);
    }
  });

  return _temp;
}

Future<Null> removeSearchItem(String value) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> searches = [];
  searches = prefs.getStringList("searchHistory");
  searches.remove(value);
  prefs.setStringList("searchHistory", searches);
}

Future<Null> saveSearchHistory(String value) async {

  //artificially limited the number of search histories saved to 40
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> searches = [];
  searches = prefs.getStringList("searchHistory") == null ?
  [] : prefs.getStringList("searchHistory");

  //append the new search query to the top
  //saved the 40 most recent
  if (searches.length + 1 > 40){

    List<String> temp = [];
    temp.add(value);

    for(int x = 0; temp.length < 41; x++){
      temp.add(searches[x]);
    }

    prefs.setStringList("searchHistory", temp);

  }else {
    prefs.setStringList("searchHistory", [value]+searches);
  }

}

Future<Null> moveQueryToTop(String value) async {

  //print("you tapped on $value");

  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> searches = [];
  searches = prefs.getStringList("searchHistory");

  //index of duplicates to remove
  List<String> _temp = [];

  //removed the current query from search history
  for (int x = 0; x < searches.length; x++){
    if (searches[x] != value){
      _temp.add(searches[x]);
    }
  }

  searches.clear();
  searches = [value] + _temp;
  //print("processed array: $searches");

  //saved the 40 most recent
  if (searches.length > 40){

    //save the first 40 only
    List<String> temp = [];
    for (int x = 0; x < 40; x++){
      temp.add(searches[x]);
    }

    prefs.setStringList("searchHistory", temp);
  } else {
    prefs.setStringList("searchHistory", searches);
  }
}