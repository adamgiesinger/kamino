import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:http/http.dart' as http;
import 'package:kamino/ui/uielements.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:kamino/view/settings/settings_prefs.dart' as settingsPref;
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kamino/vendor/dist/config/OfficialVendorConfiguration.dart'
    as vendor;

class TraktAuth extends StatefulWidget {
  @override
  _TraktAuthState createState() => new _TraktAuthState();
}

class _TraktAuthState extends State<TraktAuth> {
  // Instance of WebView plugin
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;

  @override
  void initState() {
    flutterWebviewPlugin.close();

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        print("url is now: $url");

        //String test_url = "https://trakt.tv/oauth/authorize/native?code=3032637e#";

        if (url.contains("native?code=")) {
          String authCode = url.split("code=")[1].replaceAll("#", "");

          //return to settings
          Navigator.pop(context, authCode);
        }
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String _url = "https://trakt.tv/oauth/authorize?response_type=code&"
        "client_id=${vendor.trakt_client_id}&"
        "redirect_uri=urn:ietf:wg:oauth:2.0:oob";

    return WebviewScaffold(
      url: _url,
      userAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
          "(KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36",
      clearCache: true,
      clearCookies: true,
      appBar: AppBar(
        title: TitleText("Trakt Authenticator"),
        centerTitle: true,
        elevation: 8.0,
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }

  @override
  void dispose() {
    _onUrlChanged.cancel();
    flutterWebviewPlugin.dispose();

    super.dispose();
  }
}

void renewToken(BuildContext context) async {
  //get trakt credentials
  List<String> _traktCred = [];

  settingsPref.getListPref("traktCredentials").then((data) {
    _traktCred = data;
  });

  //check if the array is empty or not
  if (_traktCred.length == 3) {
    //get the token expiry date
    DateTime temp = DateTime.parse(_traktCred[2]).toUtc();
    DateTime expiry = DateTime.utc(temp.year, temp.month, temp.day);

    //get todays date
    DateTime today = DateTime.now().toUtc();
    DateTime todaysDate = DateTime.utc(today.year, today.month, today.day);

    //check if the date has passed
    if (todaysDate.compareTo(expiry) == 0 || expiry.isBefore(todaysDate)) {
      String url = 'https://api.trakt.tv/oauth/token';

      Map body = {
        'refresh_token': _traktCred[1],
        'client_id': vendor.trakt_client_id,
        'client_secret': vendor.trakt_secret,
        'redirect_uri': 'urn:ietf:wg:oauth:2.0:oob',
        'grant_type': 'refresh_token'
      };

      http.Response res = await http.post(url, body: body);

      if (res.statusCode == 200) {
        Map data = jsonDecode(res.body);

        List<String> newCredentials = [
          data["access_token"],
          data["refresh_token"],

          //new expiry date
          DateTime.now().add(new Duration(days: 84)).toString()
        ];

        settingsPref.saveListPref("traktCredentials", newCredentials);

        Scaffold.of(context).showSnackBar(new SnackBar(
          content: Text(
            "Trakt Token Refreshed",
            style: TextStyle(
                color: Colors.white,
                fontFamily: "GlacialIndifference",
                fontSize: 17.0),
          ),
          backgroundColor: Colors.green,
          duration: new Duration(milliseconds: 600),
        ));
      } else {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) {
              return AlertDialog(
                title: TitleText("Trakt Authentication Failed"),
                content: Text(
                  "Failed to renew Trakt token, please check your "
                      "internet connection and try again. If the problem"
                      " presists sign out of trakt and login again",
                  style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "GlacialIndifference",
                      color: Colors.white),
                ),
                actions: <Widget>[
                  Center(
                    child: FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Okay",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "GlacialIndifference",
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Center(
                    child: FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        renewToken(context);
                      },
                      child: Text(
                        "Try again",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "GlacialIndifference",
                            color: Colors.white),
                      ),
                    ),
                  )
                ],
                //backgroundColor: Theme.of(context).cardColor,
              );
            });
      }
    }
  }
}

Future<Null> getCollection(List<String> traktCred) async {
  List<String> _traktMediaTypes = ["movies", "shows"];

  Map payload = {
    "movies": {"tmdb": [], "imdb": []},
    "shows": {"tmdb": [], "imdb": []},
  };

  //get the latest collection from trakt
  for (int x = 0; x < _traktMediaTypes.length; x++) {
    String element = _traktMediaTypes[x];

    String url = 'https://api.trakt.tv/sync/collection/$element';

    final res = await http.get(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${traktCred[0]}',
        HttpHeaders.contentTypeHeader: 'application/json',
        'trakt-api-version': '2',
        'trakt-api-key': vendor.trakt_client_id
      },
    );

    if (res.statusCode == 200) {
      var _data = jsonDecode(res.body);

      //get all the tmdb ids from trakt
      _data.forEach((var traktObject) {
        String mediaType = "";
        if (element == "movies") {
          mediaType = "movie";
        } else if (element == "shows") {
          mediaType = "show";
        }

        if (traktObject[mediaType]["ids"]["tmdb"] == null) {
          payload[element]["imdb"].add(traktObject[mediaType]["ids"]["imdb"]);
        } else {
          payload[element]["tmdb"].add(traktObject[mediaType]["ids"]["tmdb"]);
        }
      });
    } else {
      print("Error: ${jsonDecode(res.body)}");
    }
  }

  print("i found these ids: ${payload.toString()}");

  String status = await updateDatabase(payload);
}

Future<String> addFavToTrakt(List<String> traktCred) async {

  //get all favourites from the database
  Map _favs = await databaseHelper.getAllFaves();
  Map _body = {"movies": [], "shows": []};

  print("database log: $_favs");

  //parsing the data from the database


  //tv shows
  if (_favs["tv"].length > 0) {
    for (int i = 0; i < _favs["tv"].length; i++) {
      _body["shows"].add(
        {
          'collected_at': _favs["tv"][i]["saved_on"],
          'title': _favs["tv"][i]["name"],
          'year': _favs["tv"][i]["year"],
          'ids': {
            'tmdb': _favs["tv"][i]["tmdbID"]
          }
        },
      );
    }
  }

  //movies
  if (_favs["movie"].length > 0) {
    for (int i = 0; i < _favs["movie"].length; i++) {
      _body["movies"].add(
        {
          'collected_at': _favs["movie"][i]["saved_on"],
          'title': _favs["movie"][i]["name"],
          'year': _favs["movie"][i]["year"],
          'ids': {
            'tmdb': _favs["movie"][i]["tmdbID"]
          }
        },
      );
    }
  }

  print("sending this collection to trakt: ${jsonEncode(_body)}");

  print("sending ${_body["movies"].length} movies , ${_body["shows"].length} tv shows");


  String url = 'https://api.trakt.tv/sync/collection';

  final res = await http.post(url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${traktCred[0]}',
        HttpHeaders.contentTypeHeader: 'application/json',
        'trakt-api-version': '2',
        'trakt-api-key': vendor.trakt_client_id
      },
      body: jsonEncode(_body));

  print("trakt response code is: ${res.statusCode}");
  print("send response from trakt: ${res.body}");


  return "Sent";
}

Future<String> updateDatabase(Map payload) async {

  List<int> _favIDs = await databaseHelper.getAllFavIDs();

  //check to see if the item is already in the database
  //if not get info from tmdb and write to the database

  //processing the tv shows
  for (int i = 0; i < payload["shows"]["tmdb"].length; i++) {
    if (!_favIDs.contains(payload["shows"]["tmdb"][i])) {
      //300ms delay ensures we do not hit tmdb api limit
      await Future.delayed(new Duration(milliseconds: 300));

      //get the info from tmdb
      String url =
          "${tmdb.root_url}/tv/${payload["shows"]["tmdb"][i]}${tmdb.defaultArguments}";

      var res = await http.get(url);

      if (res.statusCode == 200) {
        Map _data = jsonDecode(res.body);

        //write the entry to the database
        databaseHelper.saveFavourites(
            _data["name"],
            "tv",
            _data["id"],
            _data["poster_path"],
            _data["first_air_date"]
        );

        _favIDs.add(_data["id"]);

        //wait 300ms before starting the next http call
        await Future.delayed(new Duration(milliseconds: 300));
      }
    }
  }

  //processing movie ids
  for (int i = 0; i < payload["movies"]["tmdb"].length; i++) {
    if (!_favIDs.contains(payload["movies"]["tmdb"][i])) {

      //print("input id: ${payload["movies"]["tmdb"][i]}");

      //300ms delay ensures we do not hit tmdb api limit
      await Future.delayed(new Duration(milliseconds: 300));

      //get the info from tmdb
      String url =
          "${tmdb.root_url}/movie/${payload["movies"]["tmdb"][i]}${tmdb.defaultArguments}";
      var res = await http.get(url);

      if (res.statusCode == 200) {
        Map _data = jsonDecode(res.body);

        //write the entry to the database
        databaseHelper.saveFavourites(
            _data["title"],
            "movie",
            _data["id"],
            _data["poster_path"],
            _data["release_date"]
        );

        _favIDs.add(_data["id"]);

        //wait 300ms before starting the next http call
        await Future.delayed(new Duration(milliseconds: 300));
      }
    }
  }

  //handling imdb ids

  //movies
  for (int i = 0; i < payload["movies"]["imdb"].length; i++) {
    //300ms delay ensures we do not hit tmdb api limit
    await Future.delayed(new Duration(milliseconds: 300));

    String url = "${tmdb.root_url}/find/${payload["movies"]["imdb"][i]}"
        "${tmdb.defaultArguments}&external_source=imdb_id";

    var res = await http.get(url);

    if (res.statusCode == 200) {
      Map _data = jsonDecode(res.body);

      //check that the data returned is not empty
      if (_data["movie_results"].length > 0) {

        if(!_favIDs.contains(_data["movie_results"][0]["id"])){

          //print("input id: ${_data["movie_results"][0]["id"]}");
          _favIDs.add(_data["movie_results"][0]["id"]);

          //write the entry to the database
          databaseHelper.saveFavourites(
              _data["movie_results"][0]["title"],
              "movie",
              _data["movie_results"][0]["id"],
              _data["movie_results"][0]["poster_path"],
              _data["movie_results"][0]["release_date"]
          );



          //wait 300ms before starting the next http call
          await Future.delayed(new Duration(milliseconds: 300));
        }

      }
    }
  }

  //tv shows
  for (int i = 0; i < payload["shows"]["imdb"].length; i++) {
    //300ms delay ensures we do not hit tmdb api limit
    await Future.delayed(new Duration(milliseconds: 300));

    String url = "${tmdb.root_url}/find/${payload["shows"]["imdb"][i]}"
        "${tmdb.defaultArguments}&external_source=imdb_id";

    var res = await http.get(url);

    if (res.statusCode == 200) {
      Map _data = jsonDecode(res.body);

      //check that the data returned is not empty
      if (_data["tv_results"].length > 0) {

        if (!_favIDs.contains(_data["tv_results"][0]["id"])) {

          //write the entry to the database
          databaseHelper.saveFavourites(
              _data["tv_results"][0]["name"],
              "tv",
              _data["tv_results"][0]["id"],
              _data["tv_results"][0]["poster_path"],
              _data["tv_results"][0]["first_air_date"]
          );

          _favIDs.add(_data["tv_results"][0]["id"]);

          //wait 300ms before starting the next http call
          await Future.delayed(new Duration(milliseconds: 300));
        }
      }
    }
  }

  return "Done";
}
