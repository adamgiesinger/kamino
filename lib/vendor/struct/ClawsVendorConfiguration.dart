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
import 'package:w_transport/vm.dart' show vmTransportPlatform;
import 'package:w_transport/w_transport.dart' as transport;

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
  Future<bool> authenticate({bool force = false}, BuildContext context) async {
    try {
      http.Response response = await http.get(server + 'api/v1/status');
      var status = Convert.jsonDecode(response.body);
    }catch(ex){
      _showAuthenticationDialog(context, "The server is offline.");
      return false;
    }
  
    final preferences = await SharedPreferences.getInstance();

    if (!force &&
        preferences.getString("token") != null &&
        preferences.getDouble("token_set_time") != null &&
        preferences.getDouble("token_set_time") + 3600 >=
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
    if (webSocket != null) {
      return webSocket.close();
    }
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
    bool canNavigate;
    try {
      Navigator.of(context).mounted;
      canNavigate = true;
    } catch (err) {
      canNavigate = false;
    }
    if (canNavigate) {
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
        } else {
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

        // No content found.
        showDialog(context: context, builder: (BuildContext ctx){
          return AlertDialog(
            title: TitleText('No Sources Found'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("We couldn't find any sources for $title."),
                ],
              )
            )
          )
        });
        
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
    String webSocketServer = server.replaceFirst(new RegExp(r'https?'), "ws");
    String endpointURL = "$webSocketServer?token=$clawsToken";
    String message = '{"type": "movies", "title": "$title"}';

    _openWebSocket(endpointURL, message, context, title);
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
    String webSocketServer = server.replaceFirst(new RegExp(r'https?'), "ws");
    String endpointURL = "$webSocketServer?token=$clawsToken";
    String data = '{"type": "tv", "title": "$title", "season": "$seasonNumber", "episode": "$episodeNumber"}';
    
    _openWebSocket(endpointURL, data, context, title, displayTitle: displayTitle);
  }

  ///
  /// This opens a WebSocket connection with Claws. Use this to get results from the
  /// server.
  ///
  _openWebSocket(String url, String data, BuildContext context, String title, {String displayTitle}) async {
    if(displayTitle == null) displayTitle = title;
  
    // Open a WebSocket connection at the API endpoint.
    try {
      webSocket = await transport.WebSocket.connect(Uri.parse(url), transportPlatform: vmTransportPlatform);
    } catch (ex) {
      print(ex.toString());
      // Just in case the app gets into a weird state. It did for me while developing. Hopefully this isn't necessary
      final isAuthenticated = await authenticate(force: true);
      if (isAuthenticated) {
        try {
          webSocket = await transport.WebSocket.connect(Uri.parse(url), transportPlatform: vmTransportPlatform);
        } on transport.WebSocketException {
          // Probably should show a message to the user here...
          print("Currently can't connect to WebSocket");
          return;
        }
      }
    }

    List<Future> futureList = [];
    List sourceList = [];
    IntByRef scrapeResultsCounter = new IntByRef(0);
    bool doneEventStatus = false;

    // Execute code when a new source is received.
    webSocket.listen((message) async {
      var event = Convert.jsonDecode(message);
      var eventName = event["event"];

      if(eventName == 'scrapeResults'){
        scrapeResultsCounter.value--;
        print('# of SCRAPE events to wait for: ' + scrapeResultsCounter.value.toString() + ". Is done scraping for results? " + doneEventStatus.toString());
        if (event.containsKey('results')) {
          List results = event['results'];
          results.forEach((result) {
            futureList.add(_onSourceFound(sourceList, result, context));
          });
        } else if (event.containsKey('error')) {
          print(event["error"]);
          return;
        }

        if (doneEventStatus && scrapeResultsCounter.value == 0) {
          print('======SCRAPE RESULTS EVENT AFTER DONE EVENT======');
          print('Server done scraping, closing WebSocket');
          webSocket.close();
          await Future.wait(futureList);
          print('All sources received');
          sourceList.sort((left, right) {
            return left['metadata']['ping'].compareTo(right['metadata']['ping']);
          });

          onComplete(context, displayTitle, sourceList);
        }
      }

      if(eventName == 'done'){
        doneEventStatus = true;
        if (scrapeResultsCounter.value == 0) {
          print('======DONE EVENT======');
          print('Server done scraping, closing WebSocket');
          webSocket.close();
          await Future.wait(futureList);
          print('All sources received');
          sourceList.sort((left, right) {
            return left['metadata']['ping'].compareTo(right['metadata']['ping']);
          });

          onComplete(context, displayTitle, sourceList);
        }

        return;
      }

      // The content can be accessed directly.
      if(eventName == 'result'){
        futureList.add(_onSourceFound(sourceList, event, context));
        return;
      }

      // Claws needs the request to be proxied.
      if(eventName == 'scrape'){
        futureList.add(_onScrapeSource(event, webSocket, scrapeResultsCounter));
        return;
      }
    }, onError: (error) {
      print("WebSocket error: " + error.toString());
    }, onDone: () {
      webSocket.close();
    });

    webSocket.add(data);
  }


  ///***** SCRAPING EVENT HANDLERS *****///
  _onSourceFound (List sourceList, data, BuildContext context, {String cookie = ''}) async {
    var sourceFile = data["file"];
    String sourceStreamURL = sourceFile["data"];

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

    Map<String, String> headers = {
      "Range": "bytes=0-125000",
      "Cookie": cookie
    };

    if (data.containsKey('headers')) {
      headers.addAll(Map.castFrom<String, dynamic, String, String>(data["headers"]));
      print("Currently can't play links that need headers");
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
      print("Parsing URL failed: $sourceStreamURL");
      return;
    }

    // Fetch HTML content from the source.
    http.Response htmlContent;
    var before = new DateTime.now().millisecondsSinceEpoch;
    try {
      htmlContent = await http.get(sourceStreamURL, headers: headers).timeout(const Duration(seconds: 5));
    }catch(ex){
      print("Error receiving stream data from source: " + ex.toString());
      return;
    }
    var ping = new DateTime.now().millisecondsSinceEpoch - before;
    if (htmlContent.statusCode < 400 && htmlContent.headers["content-type"].startsWith("video") || htmlContent.headers["content-type"].startsWith("application/octet-stream") || (sourceStreamURL.contains('clipwatching') && htmlContent.headers["content-type"].startsWith("text/plain"))) {
      data['metadata']['ping'] = ping;
    } else {
      print("Error: status: " + htmlContent.statusCode.toString() + " content-type: " + htmlContent.headers["content-type"] +  " receiving stream data from: $sourceStreamURL");
      return;
    }

    sourceList.add(data);
  }

  _onScrapeSource(event, transport.WebSocket webSocket, IntByRef scrapeResultsCounter) async {
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
    try {
      String message = Convert.jsonEncode({ "type": "resolveHtml", "resolver": event["resolver"], "cookie": cookie, "html": Convert.base64.encode(Convert.utf8.encode(htmlContent.body)) });
      webSocket.add(message);
      scrapeResultsCounter.value++;
      print('# of SCRAPE events to wait for ' + scrapeResultsCounter.value.toString());
    }catch(ex){
      print("Error receiving stream data from Claws: " + ex.toString());
    }
  }

}

class IntByRef {
  int value;
  IntByRef(this.value);
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