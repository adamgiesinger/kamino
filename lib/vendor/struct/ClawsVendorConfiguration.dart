import 'dart:async';
import 'dart:convert' as Convert;
import 'dart:math';
import 'dart:typed_data';

import 'package:cplayer/cplayer.dart';
import 'package:http/http.dart';

import 'package:kamino/api/http.dart' as http;
import 'package:kamino/api/kamino_client.dart';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/vendor/struct/LocalOfficialVendorConfiguration.dart';
import 'package:kamino/vendor/struct/LocalOfficialVendorConfigurationDelegate.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:eventsource/eventsource.dart";

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
  ///
  /// [client
  ClawsVendorConfiguration({
    @required this.name,
    @required this.server,
    @required this.clawsKey,
    this.tmdbKey,
    this.traktCredentials,
    LocalVendorConfiguration clientSideVendorDelegate,
  }) : super(name: name, tmdbKey: tmdbKey) {
    _serverUri = Uri.parse(server);

    _clientSideVendorDelegate = clientSideVendorDelegate;
    if (_clientSideVendorDelegate != null) {
      _clientSideVendorDelegate.setVendorConfiguration(this);
    }
  }

  String _token;

  // Server uri to use.
  Uri _serverUri;

  // The client side MicroService delegate. Keep as null to always use the server.
  LocalVendorConfiguration _clientSideVendorDelegate;

  ///
  /// Returns the server address declared by the Vendor.
  /// If the vendor does not use a server, this will be `localhost`
  ///
  String getServer() {
    return server;
  }

  /// Support the client-side resolver only if the local delegate was passed
  /// through.
  @override
  bool get supportsClientSideResolver {
    return _clientSideVendorDelegate != null;
  }

  @override
  Future<bool> authenticate() async {
    final preferences = await SharedPreferences.getInstance();

    // Use different preferences based on the vendor.
    final prefTokenName = "${this.name}_token";
    final prefTimeoutName = "${this.name}_token_set_time";

    var token = preferences.getString(prefTokenName);
    var lastTime = preferences.getDouble(prefTimeoutName);
    var _now = (new DateTime.now().millisecondsSinceEpoch / 1000).floor();

    // Regenerate if there's no token or our current token is about to expire
    // in less than 2 minutes.
    if ( token != null &&
        lastTime != null && lastTime - 120 >= _now) {
      // Return preferences token
      print("Re-using old token...");
      _token = token;
      return true;
    } else {
      // Return new token
      var clawsClientHash = _generateClawsHash(clawsKey);

      try {
        Response response = await http.post(generateUri('/api/v1/login'),
            body: Convert.jsonEncode({"clientID": clawsClientHash}),
            headers: {"Content-Type": "application/json"});

        var tokenResponse = Convert.jsonDecode(response.body);

        if (tokenResponse['auth']) {
          token = tokenResponse['token'];
          var tokenJson = jwtDecode(token);
          await preferences.setString(prefTokenName, token);
          await preferences.setDouble(
              prefTimeoutName, tokenJson['exp'].toDouble());
          print('Generated new token...');
          _token = token;

          return true;
        }
      } catch (e) {
        print(e);
      }
    }

    print("Unable to authenticate.");

    return false;
  }

  ///
  /// Use this method to prepare your vendor configuration.
  ///
  /// To use this, override it and call super in your new method.
  /// Returning true if the request should be made.
  ///
  Future<bool> prepare(
      String type, Map<String, String> query, BuildContext context) async {
    return true;
  }

  ///
  /// Returns the loading screen widget.
  /// Override and return a relevant widget accordingly.
  Future<T> getLoadingScreen<T>(
      String type, Map<String, String> query, BuildContext context) {
    return Interface.showAlert(
        context,
        new TitleText('Searching for Sources...'),
        [
          Row(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: new CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme
                              .of(context)
                              .primaryColor),
                    )
                ),
                Text("Please wait..."),
              ])
        ],
        false,
        [Container()]);
  }

  ///
  /// This is called when a source has been found. You can use this to either
  /// auto-play or show a source selection dialog.
  ///
  Future<void> onComplete(
      BuildContext context, String title, List sourceList) async {
    if (sourceList.length > 0) {

      sourceList.sort((left, right) {
        var leftPing = left['metadata']['ping'] ?? double.infinity;
        var rightPing = right['metadata']['ping'] ?? double.infinity;

        return leftPing.compareTo(rightPing);
      });

      Navigator.pop(context, true);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CPlayer(
                  title: title,
                  url: sourceList[0]['file']['data'],
                  mimeType: 'video/mp4')));
    } else {
      // No content found.
      showMessage('No Sources Found',
          "We couldn't find any sources for $title.", context);
    }
  }

  @override
  Future<dynamic> playMovie(String title, BuildContext context) async {
    return requestMedia(
        'movies',
        {
          'title': title,
        },
        context);
  }

  @override
  Future<dynamic> playTVShow(String title, String releaseDate, int seasonNumber,
      int episodeNumber, BuildContext context) async {
    return requestMedia(
        'tv',
        {
          'title': title,
          'season': seasonNumber.toString(),
          'episode': episodeNumber.toString(),
          'releaseDate': releaseDate,
        },
        context);
  }

  /// Where all the magic happens.
  /// Requests media links, and plays the first one it receives.
  ///
  /// Returns [StreamSubscription] or a []
  Future<dynamic> requestMedia(
      String mediaType, Map<String, String> query, BuildContext context) async {
    var loadingScreen;
    VendorSubscription subscription;
    if (await prepare(mediaType, query, context)) {
      if (await useClientServer()) {
        switch (mediaType) {
          case 'movies':
          case 'tv':
            loadingScreen = getLoadingScreen(mediaType, query, context);
            subscription =
                await _clientSideVendorDelegate.playMedia(mediaType, query, context);
            break;
          default:
            showMessage('Error', "Unsupported media type: $mediaType", context, shouldPop: false);
            break;
        }
      } else if (await authenticate()) {
        var queryParameters = Map<String, String>();
        queryParameters.addAll(query);
        queryParameters['token'] = _token;

        String title = formatTitle(
          mediaType,
          query['title'],
          query['releaseDate'],
          query['season'],
          query['episode'],
        );

        loadingScreen = getLoadingScreen(mediaType, query, context);
        try {
          subscription = await _openEventSource(
              generateUri('/api/v1/search/$mediaType', queryParameters),
              context,
              title);
        } catch (e) {
          var message = 'An unexpected error occurred.';
          if(e is EventSourceSubscriptionException) {
            var data = Convert.jsonDecode(e.message);
            if(data is Map && data['message'] != null) {
              message += "\n${data['message']}";
            }
          }
          showMessage(
              'Error', message, context, shouldPop: true);
        }
      } else {
        showMessage(
            'Error', 'Could not authenticate connection to server.', context, shouldPop: false);
      }

      if (subscription != null) {
        var result = await loadingScreen;

        // result is null if it was dismissed by the user (e.g. via back button press).
        if (result == null) {
          // Back button was pressed.

          // Cancel the event-source subscription when the user closes the
          // alert box so as not to waste resources.
          subscription.disconnect();
        }
      }
    }

    return null;
  }

  /// Whether or not to use a client-side server.
  Future<bool> useClientServer() async {
    if (_clientSideVendorDelegate == null) {
      // There's no delegate, so use the server.
      return false;
    }
    return (await SharedPreferences.getInstance())
            .getBool("useClientSideResolver") ??
        false;
  }

  ///
  /// This opens an EventSource with Claws. Use this to get results from the
  /// server.
  ///
  Future<ClawsSubscription> _openEventSource(
      Uri uri, BuildContext context, String title) async {

    // Open an event source at the API endpoint.
    EventSource eventSource = await EventSource.connect(uri, client: KaminoHttpClient(null, (error) {}));
    final subscription = new ClawsSubscription(eventSource);

    List<Future> futureList = [];
    List sourceList = [];

    // Execute code when a new source is received.
    eventSource.listen((Event message) async {
      var event = Convert.jsonDecode(message.data);
      var eventName = event["event"];

      if (subscription.disconnected) {
        return;
      }

      if (eventName == 'done') {
        await Future.wait(futureList);
        //print("futures.length(${futureList.length}), sourceList.length(${sourceList.length})");
        print('All sources received');

        if (!subscription.disconnected) {
          onComplete(context, title, sourceList);
        }
      }

      // The content can be accessed directly.
      if (eventName == 'result') {
        futureList.add(onSourceFound(
            sourceList, event, context, subscription,
            title: title));
      }

      // Claws needs the request to be proxied.
      if (eventName == 'scrape') {
        futureList.add(_onScrapeSource(
            event, sourceList, context, subscription,
            title: title));
      }
    }, cancelOnError: true);

    return subscription;
  }

  /// Show a message to the user.
  void showMessage(String title, String message, BuildContext context, {shouldPop = true}) {
    print(message);
    if (shouldPop) {
      Navigator.pop(context, true);
    }
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: TitleText(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(message),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  /// Generate the URI for the API, so that arguments are properly encoded.
  Uri generateUri(String path, [Map<String, String> query]) {
    return _serverUri.replace(path: path, queryParameters: query);
  }

  ///***** SCRAPING EVENT HANDLERS *****///
  onSourceFound(List sourceList, Map data, BuildContext context,
      VendorSubscription subscription,
      {String title, String cookie = ''}) async {

    if (subscription.disconnected) {
      return;
    }

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

    RegExp regExp = new RegExp(
        r"^(?:http(s)?://)?[\w.-]+(?:\.[\w.-]+)+[\w\-._~:/?#[\]@!$&'()*+,;=]+$");
    if (!regExp.hasMatch(sourceStreamURL)) {
      print("URL malformed: $sourceStreamURL");
      return;
    }

    try {
      Uri.parse(sourceStreamURL);
    } catch (ex) {
      print("Parsing failed: $sourceStreamURL");
      return;
    }

    // Fetch HTML content from the source.
    Response htmlContent;
    var ping;

    var before = new DateTime.now().millisecondsSinceEpoch;
    try {
      htmlContent = await http.get(sourceStreamURL, headers: {
        "Range": "bytes=0-125000",
        'Cookie': cookie
      }).timeout(const Duration(seconds: 5));
      ping = new DateTime.now().millisecondsSinceEpoch - before;

      if (htmlContent.statusCode < 400 &&
          htmlContent.headers["content-type"].startsWith("video")) {
        data['metadata']['ping'] = ping;
      } else {
        print("Error: status: " +
            htmlContent.statusCode.toString() +
            " content-type: " +
            htmlContent.headers["content-type"] +
            " receiving stream data from: $sourceStreamURL");
        return;
      }
    } catch (ex) {
      // Keep it in case the user's network is just slow, but reduce its priority.
      print('Error: could not fetch ping for stream source.');
    }

    sourceList.add(data);
  }

  _onScrapeSource(event, List sourceList, BuildContext context,
      VendorSubscription subscription,
      {String title}) async {

    if (event['headers'] == null) {
      event['headers'] = new Map<String, String>();
    }

    // Fetch HTML content from the source.
    Response htmlContent;
    var cookie = '';
    try {
      htmlContent = await http.get(event['target'], headers: event['headers']);
      if (event['cookieRequired'] != '') {
        var cookieKey = event['cookieRequired'];
        var cookieList = htmlContent.headers['set-cookie'].split(',');
        cookie = cookieList
            .lastWhere((String i) => i.contains(cookieKey))
            .split(';')
            .firstWhere((String i) => i.contains(cookieKey));
      }
    } catch (ex) {
      print("Error receiving stream data from source: " + ex.toString());
      return;
    }

    if (subscription.disconnected) {
      // Don't post to the server if we've already disconnected from the server.
      return;
    }

    // POST the HTML content to Claws which will find the link.
    Response response;
    try {
      response = await http.post(generateUri(event['resolver']),
          headers: {"Content-Type": "application/json"},
          body: Convert.jsonEncode({
            "html": Convert.base64.encode(Convert.utf8.encode(htmlContent.body))
          }));

      List sources = Convert.jsonDecode(response.body);

      for (var i = 0; i < sources.length; i++) {
        await onSourceFound(sourceList, sources[i], context, subscription,
            title: title, cookie: cookie);
      }
    } catch (ex) {
      print("Error receiving stream data from Claws: " + ex.toString());
      return;
    }
  }
}

///******* libClaws *******///
String _generateClawsHash(String clawsClientKey) {
  final randGen = Random.secure();

  Uint8List ivBytes =
      Uint8List.fromList(new List.generate(8, (_) => randGen.nextInt(128)));
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
    return Uri.decodeFull(
        Convert.utf8.decode(Convert.base64Url.decode(output)));
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

  ClawsLoadingState(
      {this.text: "",
      this.progress: 0,
      this.foundSources: 0,
      this.analyzedSources: 0});
}

class ClawsSubscription extends VendorSubscription {

  EventSource eventSource;

  ClawsSubscription(this.eventSource);

  void disconnect() {
    disconnected = true;
    eventSource.client.close();
  }
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
