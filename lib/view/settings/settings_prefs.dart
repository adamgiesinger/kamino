import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


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