import 'dart:async';
import 'dart:convert' as Convert;
import 'dart:math';
import 'dart:typed_data';

import 'package:cplayer/cplayer.dart';
import 'package:http/http.dart' as http;

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino/models/source.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/util/settings.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';
import 'package:kamino/vendor/view/SearchingSourcesDialog.dart';
import 'package:kamino/vendor/view/SourceSelectionView.dart';
import 'package:meta/meta.dart';
import 'package:w_transport/vm.dart' show vmTransportPlatform;
import 'package:w_transport/w_transport.dart' as transport;
import 'package:ntp/ntp.dart';
import 'package:pool/pool.dart';

class ClawsVendorConfiguration extends VendorConfiguration {

  ClawsVendorDelegate _delegate;

  // Settings
  static const bool ALLOW_SOURCE_SELECTION = true;
  static const bool FORCE_TOKEN_REGENERATION = true;

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

  Future<bool> sourceSelectionEnabled() async {
    return ALLOW_SOURCE_SELECTION && await (Settings.manuallySelectSourcesEnabled);
  }

  @override
  Future<bool> authenticate(BuildContext context, {bool force = false}) async {
    try {
      http.Response response = await http.get(server + 'api/v1/status').timeout(Duration(seconds: 10), onTimeout: (){
        Navigator.of(context).pop();
        _showAuthenticationFailureDialog(context, "The request timed out.\n\n(Is your connection too slow?)");
      });
      var status = Convert.jsonDecode(response.body);
    }catch(ex){
      print(ex);
      Navigator.of(context).pop();
      _showAuthenticationFailureDialog(context, "Claws is currently offline for server upgrades.\nPlease check the #announcements channel in our Discord server for more information.");
      return false;
    }

    String clawsToken = await Settings.clawsToken;
    double clawsTokenSetTime = await Settings.clawsTokenSetTime;

    DateTime now = await NTP.now();
    if (!FORCE_TOKEN_REGENERATION && !force &&
        clawsToken != null &&
        clawsTokenSetTime != null &&
        clawsTokenSetTime + 3600 >=
            (now.millisecondsSinceEpoch / 1000).floor()) {
      // Return preferences token
      print("Re-using old token...");
      _token = clawsToken;
      return true;
    } else {
      // Return new token
      var clawsClientHash = await _generateClawsHash(clawsKey, now).timeout(Duration(seconds: 5), onTimeout: () async {
        Navigator.of(context).pop();
        _showAuthenticationFailureDialog(context, "Authentication timed out.\n\nPlease try again.");
      });
      http.Response response = await http.post(server + 'api/v1/login',
          body: Convert.jsonEncode({"clientID": clawsClientHash}),
          headers: {"Content-Type": "application/json"}).timeout(Duration(seconds: 10), onTimeout: () async {
        Navigator.of(context).pop();
        _showAuthenticationFailureDialog(context, "Authentication timed out.\n\nPlease try again.");
      });

      var tokenResponse = Convert.jsonDecode(response.body);

      if (tokenResponse["auth"]) {
        var token = tokenResponse["token"];
        var tokenJson = jwtDecode(token);
        await (Settings.clawsToken = token);
        await (Settings.clawsTokenSetTime = tokenJson['exp'].toDouble());
        print("Generated new token...");
        _token = token;

        return true;
      } else {
        _showAuthenticationFailureDialog(context, tokenResponse["message"]);
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
    if (_delegate != null && !_delegate.inClosedState) _delegate.close();
    _delegate = new ClawsVendorDelegate();

    showDialog(
      context: context,
      builder: (BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: TitleText('Connecting...'),
          content: SingleChildScrollView(
            child: Row(
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
          )
        ),
      )
    );
  }

  ///
  /// This is called when a source has been found. You can use this to either
  /// auto-play or show a source selection dialog.
  ///
  Future<void> onComplete(BuildContext context, String title) async {
    //Navigator.of(context).pop();

    if(_delegate.sourceList.length > 0) {
      if(await sourceSelectionEnabled()){
        return;
        /*Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SourceSelectionView(
              sourceList: sourceList.toSet().toList(), // to set, then back to list to eliminate duplicates
              title: title,
            ))
        );*/
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>
                CPlayer(
                    title: title,
                    url: _delegate.sourceList[0].file.data,
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
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Theme.of(context).primaryColor,
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );

      });

    }
  }

  Future<void> _showAuthenticationFailureDialog(BuildContext context, String reason) async {
    if(reason == null){
      reason = "Unable to determine reason...";
    }

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
  Future<void> playMovie(String title, String releaseDate, BuildContext context) async {
    await prepare(title, context);

    // Get year from release date
    var year = new DateFormat.y("en_US").format(DateTime.parse(releaseDate) ?? '');

    var authenticationStatus = await authenticate(context);
    if(!authenticationStatus) return Navigator.of(context).pop();

    // Connect to Claws
    String clawsToken = _token;
    String webSocketServer = server.replaceFirst(new RegExp(r'https?'), "ws").replaceFirst(new RegExp(r'http?'), "ws");
    String endpointURL = "$webSocketServer?token=$clawsToken";
    String data = '{"type": "movies", "title": "$title", "year": "$year"}';

    _openWebSocket(endpointURL, data, context, title);
  }

  @override
  Future<void> playTVShow(String title, String releaseDate, int seasonNumber, int episodeNumber, BuildContext context) async {
    await prepare(title, context);

    // Format title
    var displayTitle = "$title - ${seasonNumber}x$episodeNumber";
    // Get year from release date
    var year = new DateFormat.y("en_US").format(DateTime.parse(releaseDate) ?? '');

    var authenticationStatus = await authenticate(context);
    if(!authenticationStatus) return Navigator.of(context).pop();

    // Connect to Claws
    String clawsToken = _token;
    String webSocketServer = server.replaceFirst(new RegExp(r'https?'), "ws").replaceFirst(new RegExp(r'http?'), "ws");
    String endpointURL = "$webSocketServer?token=$clawsToken";
    String data = '{"type": "tv", "title": "$title", "year": "$year", "season": "$seasonNumber", "episode": "$episodeNumber"}';

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
      _delegate.open(await transport.WebSocket.connect(Uri.parse(url), transportPlatform: vmTransportPlatform).timeout(Duration(seconds: 10)));
      
      if(await sourceSelectionEnabled()){
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => WillPopScope(
              child: SourceSelectionView(
                  title: title,
                  delegate: _delegate
              ),
              onWillPop: () async {
                _delegate.cancel();
              },
            )
        ));
      }else {
        Navigator.of(context).pop();
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => WillPopScope(
              child: SearchingSourcesDialog(onCancel: () async {
                _delegate.cancel();
              }),
              onWillPop: () async {
                _delegate.cancel();
                Navigator.of(context).pop();
                return false;
              },
            )
        );
      }
    } catch (ex) {
      Navigator.of(context).pop();
      _showAuthenticationFailureDialog(context, "Connection failed. Please try again.");
      print(ex.toString());
      return;
    }

    List<Function> futureList = [];
    IntByRef scrapeResultsCounter = new IntByRef(0);
    bool doneEventStatus = false;

    // Execute code when a new source is received.
    _delegate.socket.listen((message) async {
      if(_delegate.wasCancelled || _delegate.inClosedState) return;

      var event = Convert.jsonDecode(message);
      var eventName = event["event"];

      if(eventName == 'scrapeResults'){
        scrapeResultsCounter.value--;
        //print('# of SCRAPE events to wait for: ' + scrapeResultsCounter.value.toString() + ". Is done scraping for results? " + doneEventStatus.toString());
        if (event.containsKey('results')) {
          List results = event['results'];
          results.forEach((result) {
            futureList.add(() => _onSourceFound(result, context));
          });
        } else if (event.containsKey('error')) {
          print(event["error"]);
          return;
        }

        if (doneEventStatus && scrapeResultsCounter.value == 0) {
          //print('======SCRAPE RESULTS EVENT AFTER DONE EVENT======');
          _onDelegateComplete(context, displayTitle, futureList);
        }
      }

      if(eventName == 'done'){
        doneEventStatus = true;
        if (scrapeResultsCounter.value == 0) {
          _onDelegateComplete(context, displayTitle, futureList);
        }

        return;
      }

      // The content can be accessed directly.
      if(eventName == 'result'){
        futureList.add(() => _onSourceFound(event, context));
        return;
      }

      // Claws needs the request to be proxied.
      if(eventName == 'scrape'){
        futureList.add(() => _onScrapeSource(event, _delegate.socket, scrapeResultsCounter));
        return;
      }
    }, onError: (error) {
      print("WebSocket error: " + error.toString());
    }, onDone: () {
      _delegate.close();
    });

    _delegate.socket.add(data);
  }

  _onDelegateComplete(BuildContext context, String displayTitle, List<Function> futureList) async {
    print('====== DELEGATE COMPLETE ======');
    print('Server done scraping, closing WebSocket');

    print("Processing received scrape information...");
    // Max concurrent requests
    int maxConcurrentRequests = await (Settings.maxConcurrentRequests);
    // Request timeout in settings
    int requestTimeout = await (Settings.requestTimeout);

    Pool pool = new Pool(maxConcurrentRequests, timeout: new Duration(seconds: requestTimeout));
    for(Function function in futureList){
      pool.withResource(() async {
        return function();
      });
    }
    await pool.close();

    print('Done processing.');
    _delegate.close();

    onComplete(context, displayTitle);
  }

  ///***** SCRAPING EVENT HANDLERS *****///
  _onSourceFound (data, BuildContext context, {String cookie = ''}) async {
    var sourceFile = data["file"];
    String sourceStreamURL = sourceFile["data"];

    if (data['metadata']['isStreamable']) {
      print("Link is not streamable");
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
      htmlContent = await http.get(sourceStreamURL, headers: headers).timeout(Duration(seconds: 10));
    }catch(ex){
      print("Error receiving stream data from source (_onSourceFound): " + ex.toString());
      return;
    }
    var ping = new DateTime.now().millisecondsSinceEpoch - before;
    if (htmlContent.statusCode < 400 && htmlContent.headers["content-type"].startsWith("video") || htmlContent.headers["content-type"].startsWith("application/octet-stream") || (sourceStreamURL.contains('clipwatching') && htmlContent.headers["content-type"].startsWith("text/plain"))) {
      data['metadata']['ping'] = ping;
    } else {
      print("Error: status: " + htmlContent.statusCode.toString() + " content-type: " + htmlContent.headers["content-type"] +  " receiving stream data from: $sourceStreamURL");
      return;
    }

    print(data);
    _delegate.addSource(SourceModel.fromJSON(data));
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
      print("Error receiving stream data from source (_onScrapeSource): " + ex.toString());
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

  @override
  Future<void> cancel() async {
    if(_delegate != null) _delegate.cancel();
  }

}

class IntByRef {
  int value;
  IntByRef(this.value);
}

///******* libClaws *******///
Future<String> _generateClawsHash(String clawsClientKey, DateTime now) async {
  final randGen = Random.secure();

  Uint8List ivBytes = Uint8List.fromList(new List.generate(8, (_) => randGen.nextInt(128)));
  String ivHex = formatBytesAsHexString(ivBytes);
  String iv = Convert.utf8.decode(ivBytes);

  final key = clawsClientKey.substring(0, 32);
  final encrypter = new Encrypter(new Salsa20(key, iv));
  num time = (now.millisecondsSinceEpoch / 1000).floor();
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

class ClawsVendorDelegate {

  List<SourceModel> sourceList;

  List<Function> sourceEvents;
  List<Function> closeEvents;

  transport.WebSocket _webSocket;
  int _connectionStatus;

  ClawsVendorDelegate(){
    // -1 -> Unused connection
    _connectionStatus = -1;
  }

  transport.WebSocket get socket => _webSocket;

  int get status => _connectionStatus;

  bool get inUnusedState => status == -1;
  bool get inClosedState => status == 0 || status == 449;
  bool get wasCancelled => status == 449;

  void addSourceEvent(Function onSource){
    sourceEvents.add(onSource);
  }

  void clearSourceEvents(){
    sourceEvents.clear();
  }

  void addSource(SourceModel model){
    sourceList.add(model);
    if(sourceEvents != null) sourceEvents.forEach((func) => func(model));
  }

  List<SourceModel> getSources(){
    return sourceList;
  }

  void addCloseEvent(Function onClose){
    closeEvents.add(onClose);
  }

  void clearCloseEvents(){
    closeEvents.clear();
  }

  ClawsVendorDelegate open(transport.WebSocket socket) {
    sourceEvents = new List();
    closeEvents = new List();

    sourceList = new List();

    if(wasCancelled) return null;
    if (!inUnusedState) throw new Exception(
        "Tried to open cancelled or already open connection!");

    _connectionStatus = 1;
    _webSocket = socket;

    return this;
  }

  void close(){
    if(closeEvents != null) closeEvents.forEach((func) => func());

    // Ignore if already in closed state.
    if(inClosedState || inUnusedState) return;

    // Connection closed.
    _connectionStatus = 0;
    if(_webSocket != null) _webSocket.close();
  }

  void cancel(){
    // Ignore if already in closed state.
    if(inClosedState) return;

    // Connection cancelled.
    _connectionStatus = 449;
    if(_webSocket != null) _webSocket.close(4449, "Client terminated connection.");
  }

}
