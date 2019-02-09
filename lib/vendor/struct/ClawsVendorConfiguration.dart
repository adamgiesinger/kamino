import 'dart:async';
import 'dart:convert' as Convert;
import 'dart:math';
import 'dart:typed_data';

import 'package:cplayer/cplayer.dart';
import 'package:http/http.dart' as http;

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';
import 'package:kamino/view/sourceSelectionView.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:w3c_event_source/event_source.dart';

class ClawsVendorConfiguration extends VendorConfiguration {

  // Settings
  static const bool ALLOW_SOURCE_SELECTION = true;

  // Keys
  final String clawsKey;
  final String tmdbKey;
  final TraktCredentials traktCredentials;

  // Metadata
  final String name;
  final String server;


  /// [name]    - The name of the vendor. If you are developing this independently,
  ///           use your GitHub name.
  ///
  /// [server]  - The server address of the vendor. Used to determine which source
  ///           should be used.
  ///           If you are using Claws, this is the address of your Claws instance,
  ///           including the port, protocol and trailing slash.
  ClawsVendorConfiguration({
    @required this.name,
    @required this.server,

    @required this.clawsKey,

    this.tmdbKey,
    this.traktCredentials
  }) : super(name: name, tmdbKey: tmdbKey);

  String _token;

  ///
  /// Returns the server address declared by the Vendor.
  /// If the vendor does not use a server, this will be `localhost`
  ///
  String getServer(){
    return server;
  }

  @override
  Future<bool> authenticate(BuildContext context) async {
    try {
      http.Response response = await http.get(server + 'api/v1/status');
      var status = Convert.jsonDecode(response.body);
    }catch(ex){
      _showAuthenticationDialog(context, "The server is offline.");
      return false;
    }
    final preferences = await SharedPreferences.getInstance();

    if ( // Add a false condition here to force token refresh.
    preferences.getString("token") != null &&
        preferences.getDouble("token_set_time") != null &&
        preferences.getDouble("token_set_time") + 1300 >=
            (new DateTime.now().millisecondsSinceEpoch / 1000).floor()) {
      // Return preferences token
      print("Re-using old token...");
      _token = preferences.getString("token");
      return true;
    } else {
      // Return new token
      var clawsClientHash = _generateClawsHash(clawsKey);
      http.Response response = await http.post(server + 'api/v1/login',
          body: Convert.jsonEncode({"clientID": clawsClientHash}),
          headers: {"Content-Type": "application/json"});

      var tokenResponse = Convert.jsonDecode(response.body);

      if (tokenResponse["auth"]) {
        var token = tokenResponse["token"];
        var tokenJson = jwtDecode(token);
        await preferences.setString("token", token);
        await preferences.setDouble("token_set_time", tokenJson['exp'].toDouble());
        print("Generated new token...");
        _token = token;

        return true;
      } else {
        _showAuthenticationDialog(context, tokenResponse["message"]);
        return false;
      }
    }
  }

  ///
  /// Use this method to prepare your vendor configuration or to show
  /// loading messages.
  ///
  /// To use this, override it and call super in your new method.
  ///
  Future<void> prepare(String title, BuildContext context) async {
    showDialog(barrierDismissible: false, context: context, builder: (BuildContext ctx){
      return AlertDialog(
        title: TitleText('Searching for sources...'),
        content: SingleChildScrollView(
          child:
            Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
                    child: new CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor
                      ),
                    )
                ),
                Center(child: Text("Please wait..."))
              ],
            ),
        ),
      );
    });
  }

  ///
  /// This is called when a source has been found. You can use this to either
  /// auto-play or show a source selection dialog.
  ///
  Future<void> onComplete(BuildContext context, String title, List sourceList) async {
    if(sourceList.length > 0) {

      SharedPreferences preferences = await SharedPreferences.getInstance();

      if(preferences.getBool("sourceSelection")){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SourceSelectionView(
              sourceList: sourceList,
              title: title,
            ))
        );
      }else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                CPlayer(
                    title: title,
                    url: sourceList[0]['file']['data'],
                    mimeType: 'video/mp4'
                ))
        );
      }

    }else{

      Navigator.of(context).pop();

      // No content found.
      showDialog(context: context, builder: (BuildContext ctx){
        return AlertDialog(
          title: TitleText('No Sources Found'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("We couldn't find any sources for $title."),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });

    }
  }

  Future<void> _showAuthenticationDialog(BuildContext context, String reason) async {
    Navigator.of(context).pop();
    Interface.showAlert(
        context,
        TitleText("Unable to connect..."), // Title
        <Widget>[
          Text(reason)
        ],
        true,
        [
          new FlatButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text("Close"),
              textColor: Theme.of(context).primaryColor,
          )
        ]
    );
  }

  @override
  Future<void> playMovie(String title, BuildContext context) async {
    await prepare(title, context);

    var authenticationStatus = await authenticate(context);
    if(!authenticationStatus) return;

    // Connect to Claws
    String clawsToken = _token;
    String endpointURL = "${server}api/v1/search/movies?title=$title&token=$clawsToken";

    _openEventSource(endpointURL, context, title);
  }

  @override
  Future<void> playTVShow(String title, String releaseDate, int seasonNumber, int episodeNumber, BuildContext context) async {
    await prepare(title, context);

    // Format title
    var displayTitle = "$title - ${seasonNumber}x$episodeNumber";
    var year = new DateFormat.y("en_US").format(DateTime.parse(releaseDate));
    title = "$title ($year)";

    var authenticationStatus = await authenticate(context);
    if(!authenticationStatus) return;

    // Connect to Claws
    String clawsToken = _token;
    String endpointURL = "${server}api/v1/search/tv?title=$title&season=$seasonNumber&episode=$episodeNumber&token=$clawsToken";

    _openEventSource(endpointURL, context, title, displayTitle: displayTitle);
  }

  ///
  /// This opens an EventSource with Claws. Use this to get results from the
  /// server.
  ///
  _openEventSource(String url, BuildContext context, String title, {String displayTitle}){
    if(displayTitle == null) displayTitle = title;

    // Open an event source at the API endpoint.
    final sourceListener = new EventSource(Uri.parse(url));

    List<Future> futureList = [];
    List sourceList = [];

    // Execute code when a new source is received.
    StreamSubscription<MessageEvent> resultSubscription;
    resultSubscription = sourceListener.events.listen((MessageEvent message) async {
      var event = Convert.jsonDecode(message.data);
      var eventName = event["event"];

      if(eventName == 'done'){
        print('Server done scraping, closing Event Source');
        resultSubscription.cancel();

        await Future.wait(futureList);
        print('All sources received');
        sourceList.sort((left, right) {
          return left['metadata']['ping'].compareTo(right['metadata']['ping']);
        });

        onComplete(context, displayTitle, sourceList);
      }

      // The content can be accessed directly.
      if(eventName == 'result'){
        futureList.add(_onSourceFound(sourceList, Convert.jsonDecode(message.data), context, resultSubscription, title: title));
      }

      // Claws needs the request to be proxied.
      if(eventName == 'scrape'){
        futureList.add(_onScrapeSource(event, sourceList, context, resultSubscription, title: title));
      }
    });
  }


  ///***** SCRAPING EVENT HANDLERS *****///
  _onSourceFound (List sourceList, data, BuildContext context, StreamSubscription<MessageEvent> resultSubscription, {String title, String cookie = ''}) async {
    var sourceFile = data["file"];
    var sourceStreamURL = sourceFile["data"];

    if (data['metadata']['isDownload']) {
      print("Currently can't play download links");
      return;
    }

    if (cookie != '') {
      data['metadata']['cookie'] = cookie;
      return;
    } else if (cookie == '' && data['metadata']['cookie'] != '') {
      cookie = data['metadata']['cookie'];
    }

    if (cookie != '') {
      print("Currently can't play links that need cookies");
      return;
    }

    RegExp regExp = new RegExp(r"^(?:http(s)?://)?[\w.-]+(?:\.[\w.-]+)+[\w\-._~:/?#[\]@!$&'()*+,;=]+$");
    if (!regExp.hasMatch(sourceStreamURL)) {
      print("URL malformed: $sourceStreamURL");
      return;
    }

    try {
      Uri.parse(sourceStreamURL);
    }catch(ex){
      print("Parsing failed: $sourceStreamURL");
      return;
    }

    // Fetch HTML content from the source.
    http.Response htmlContent;
    var before = new DateTime.now().millisecondsSinceEpoch;
    try {
      htmlContent = await http.get(sourceStreamURL, headers: {"Range": "bytes=0-125000", 'Cookie': cookie}).timeout(const Duration(seconds: 5));
    }catch(ex){
      print("Error receiving stream data from source: " + ex.toString());
      return;
    }
    var ping = new DateTime.now().millisecondsSinceEpoch - before;
    if (htmlContent.statusCode < 400 && htmlContent.headers["content-type"].startsWith("video")) {
      data['metadata']['ping'] = ping;
    } else {
      print("Error: status: " + htmlContent.statusCode.toString() + " content-type: " + htmlContent.headers["content-type"] +  " receiving stream data from: $sourceStreamURL");
      return;
    }

    sourceList.add(data);
  }

  _onScrapeSource(event, List sourceList, BuildContext context, StreamSubscription<MessageEvent> resultSubscription, {String title}) async {
    String clawsToken = _token;
    String instanceWithoutTrailing = getServer().substring(0, getServer().length - 1);

    if(event["headers"] == null){
      event["headers"] = new Map<String, String>();
    }

    // Fetch HTML content from the source.
    http.Response htmlContent;
    var cookie = '';
    try {
      htmlContent = await http.get(
          event["target"],
          headers: event["headers"]
      );
      if (event['cookieRequired'] != '') {
        var cookieKey = event['cookieRequired'];
        var cookieList = htmlContent.headers['set-cookie'].split(',');
        cookie = cookieList.lastWhere((String i) => i.contains(cookieKey)).split(';').firstWhere((String i) => i.contains(cookieKey));
      }
    }catch(ex){
      print("Error receiving stream data from source: " + ex.toString());
      return;
    }

    // POST the HTML content to Claws which will find the link.
    http.Response response;
    try {
      response = await http.post(
          instanceWithoutTrailing + event["resolver"] +
              "?token=$clawsToken",
          headers: { "Content-Type": "application/json" },
          body: Convert.jsonEncode({ "html": Convert.base64.encode(Convert.utf8.encode(htmlContent.body)) })
      );

      List sources = Convert.jsonDecode(response.body);

      for (var i = 0; i < sources.length; i++) {
        await _onSourceFound(sourceList, sources[i], context, resultSubscription, title: title, cookie: cookie);
      }

    }catch(ex){
      print("Error receiving stream data from Claws: " + ex.toString());
      return;
    }
  }

}

///******* libClaws *******///
String _generateClawsHash(String clawsClientKey) {
  final randGen = Random.secure();

  Uint8List ivBytes = Uint8List.fromList(new List.generate(8, (_) => randGen.nextInt(128)));
  String ivHex = formatBytesAsHexString(ivBytes);
  String iv = Convert.utf8.decode(ivBytes);

  final key = clawsClientKey.substring(0, 32);
  final encrypter = new Encrypter(new Salsa20(key, iv));
  num time = (new DateTime.now().millisecondsSinceEpoch / 1000).floor();
  final plainText = "$time|$clawsClientKey";
  final encryptedText = encrypter.encrypt(plainText);

  return "$ivHex|$encryptedText";
}

String formatBytesAsHexString(Uint8List bytes) {
  var result = StringBuffer();
  for (var i = 0; i < bytes.lengthInBytes; i++) {
    var part = bytes[i];
    result.write('${part < 16 ? '0' : ''}${part.toRadixString(16)}');
  }
  return result.toString();
}

String base64UrlDecode(String str) {
  String output = str.replaceAll("-", "+").replaceAll("_", "/");
  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += "==";
      break;
    case 3:
      output += "=";
      break;
    default:
      throw "Illegal base64url string!";
  }

  try {
    return Uri.decodeFull(Convert.utf8.decode(Convert.base64Url.decode(output)));
  } catch (err) {
    return Convert.utf8.decode(Convert.base64Url.decode(output));
  }
}

dynamic jwtDecode(token) {
  try {
    return Convert.jsonDecode(base64UrlDecode(token.split('.')[1]));
  } catch (e) {
    throw "Invalid token specified: " + e.message;
  }
}

class ClawsLoadingState {

  String text;
  double progress;

  int analyzedSources;
  int foundSources;

  ClawsLoadingState({
    this.text: "",
    this.progress: 0,

    this.foundSources: 0,
    this.analyzedSources: 0
  });

}

///******* Loader *******///

class LoadingWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => LoadingWidgetState();

}

class LoadingWidgetState extends State<LoadingWidget> {

  @override
  Widget build(BuildContext context) {
    return Container();
  }

}