import 'dart:async';

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/src/helpers.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_user_agent/flutter_user_agent.dart';

import 'package:intl/intl.dart';
import 'package:cplayer/cplayer.dart';
import 'package:flutter/material.dart';

import 'package:kamino/vendor/struct/LocalOfficialVendorConfiguration.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:w3c_event_source/event_source.dart';

/// Base official vendor that provides the ability to use either a client-side
/// node "server" or a remote one.
///
/// It determines whether to use the client-side server by reading off
/// a SharedPreference set in the settings.
class BaseOfficialVendorConfiguration extends VendorConfiguration {
  // The client side MicroService delegate. Keep as null to always use the server.
  LocalVendorConfiguration _clientSideVendorDelegate;

  Uri _serverUri;

  String _token;
  String _secretClientId;

  SharedPreferences _sharedPreferences;

  bool _useBcrypt = false;

  BaseOfficialVendorConfiguration(
      {@required String server,
      @required String tmdbApiKey,
      @required String secretClientId,
      LocalVendorConfiguration clientSideVendorDelegate,
      name = "OfficialVendor"})
      : super(
          name: name,
          server: server,
          tmdb_api_key: tmdbApiKey,
        ) {
    _serverUri = Uri.parse(server);
    _secretClientId = secretClientId;
    _clientSideVendorDelegate = clientSideVendorDelegate;

    if (_clientSideVendorDelegate != null) {
      _clientSideVendorDelegate.setVendorConfiguration(this);
    }
  }

  ///
  /// Authenticate communication with the server.
  ///
  /// It's used to periodically update the [_token] variable.
  ///
  @override
  Future<bool> authenticate() async {
    await _getSharedPreferences();

    var tokenConfigName = "${this.name}Token";

    var token = _sharedPreferences.getString(tokenConfigName);

    var now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

    if (token != null) {
      var tokenStatus = parseJwt(token);
      if (now < tokenStatus['exp']) {
        // The token is still valid. No need to regenerate.
        _token = token;
        return true;
      }
    }

    var clientId, pass;

    // Depending on your server version, use Salsa20 or Bcrypt.
    if (_useBcrypt) {
      var dbCrypt = new DBCrypt();
      pass = '$now|$_secretClientId';
      clientId = dbCrypt.hashpw(pass, dbCrypt.gensalt());
    } else {
      final String iv = _generateIv();
      final encrypter = new Encrypter(
          new Salsa20(_secretClientId.substring(0, 32), iv));
      pass = '$now|$_secretClientId';
      final encryptedString = encrypter.encrypt(pass);
      var ivHex = formatBytesAsHexString(Uint8List.fromList(iv.codeUnits));
      clientId = '$ivHex|$encryptedString';
    }

    try {
      var response = await http.post(generateUri('/api/v1/login'),
          headers: {
            'Content-type': 'application/json',
          },
          body: jsonEncode({
            'clientID': clientId,
          }));
      var data = jsonDecode(response.body);
      if (data['auth']) {
        _token = data['token'];
        _sharedPreferences.setString(tokenConfigName, _token);
        return true;
      }
    } catch (e) {
      print("Could not authenticate token: $e");
    }
    return false;
  }

  @override
  Future<dynamic> playMovie(String title, BuildContext context) async {
    if (await useClientServer()) {
      return _clientSideVendorDelegate.playMovie(title, context);
    } else if (await authenticate()) {
      return requestLinks(
          'movies',
          {
            'title': title,
          },
          context);
    } else {
      Navigator.pop(context, true);
      showMessage('Could not authenticate connection to server.', context);
    }
  }

  @override
  Future<dynamic> playTVShow(String name, String releaseDate, int seasonNumber,
      int episodeNumber, BuildContext context) async {
    if (await useClientServer()) {
      return _clientSideVendorDelegate.playTVShow(
          name, releaseDate, seasonNumber, episodeNumber, context);
    }
    if (await authenticate()) {
      return requestLinks(
          'tv',
          {
            'title': name,
            'season': seasonNumber.toString(),
            'episode': episodeNumber.toString(),
            'releaseDate': releaseDate,
          },
          context);
    } else {
      Navigator.pop(context, true);
      showMessage('Could not authenticate connection to server.', context);
    }
  }

  /// Where all the magic happens.
  /// Requests media links, and plays the first one it receives.
  Future<StreamSubscription> requestLinks(
      String type, Map<String, String> query, BuildContext context) async {
    var queryParameters = Map<String, String>();
    queryParameters.addAll(query);
    queryParameters['token'] = _token;

    final source =
        EventSource(generateUri('/api/v1/search/$type', queryParameters));
    StreamSubscription subscription;
    try {
      int scrapeEvents = 0;
      bool waitingForScrapes = false;

      var timer = Timer(Duration(seconds: 65), () {
        // Attempt to disconnect from the server after 65 seconds.
        disconnect(source, context, 'Could not resolve any links.');
      });

      subscription = source.events.listen((MessageEvent message) async {
        var data = jsonDecode(message.data);
        switch (data['event']) {
          case 'result':
            // Received a link.
            if (disconnect(source, context)) {
              openVideo(
                  formatTitle(
                    query['title'],
                    query['releaseDate'],
                    query['season'],
                    query['episode'],
                  ),
                  data['file']['data'],
                  data['file']['kind'],
                  context);
            }
            break;
          case 'scrape':
            if (source.readyState == EventSource.CLOSED) {
              // Already resolved, ignore it.
              return;
            }
            scrapeEvents++;

            // Apply the device's user agent when requesting rather than sending
            // "Dart/2.1 (dart:io)"
            if (data['header'] == null) {
              data['header'] = Map<String,String>();
            }
            data['header']['user-agent'] = await _getUserAgent();

            http.read(data['target'], headers: data['header']).then((content) {
              if (source.readyState == EventSource.CLOSED) {
                // Already closed, ignore it.
                return null;
              }

              return http.post(generateUri(data['resolver']),
                  body: jsonEncode({
                    'html': base64Encode(utf8.encode(content)),
                  }),
                  headers: {
                    'Content-type': 'application/json',
                  }).then((response) {
                if (response.statusCode == 200) {
                  List data = jsonDecode(response.body);
                  if (data.length > 0) {
                    var datum = data[0];
                    if (disconnect(source, context)) {
                      openVideo(
                          formatTitle(
                            query['title'],
                            query['releaseDate'],
                            query['season'],
                            query['episode'],
                          ),
                          datum['file']['data'],
                          datum['file']['kind'],
                          context);
                    }
                  }
                }
              }, onError: (error) {
                print(
                    '${data['resolver']} [${data['target']}] resolver, unexpected error occurred: $error');
              });
            }, onError: (error) {
              print('link resolver, unexpected error occurred: $error');
            }).whenComplete(() {
              scrapeEvents--;
              if (waitingForScrapes && scrapeEvents == 0) {
                disconnect(source, context, 'Could not resolve any links');
                timer.cancel();
              }
            });
            break;
          case 'done':
            if (scrapeEvents > 0) {
              // We have scrape events that need resolving.
              // Wait for them...
              waitingForScrapes = true;
            } else {
              disconnect(source, context, 'Could not resolve any links');
              timer.cancel();
            }
            break;
        }
      }, onError: (error) {
        print('Could not connect to the eventstream: $error');
        disconnect(source, context, 'Could not resolve any links.');
      }, cancelOnError: true);

      return subscription;
    } catch (e) {
      print(e);

      return null;
    }
  }

  bool disconnect(EventSource source, BuildContext context, [String message]) {
    if (source.readyState == EventSource.CLOSED) {
      // Already closed, ignore it. We don't want to accidentally pop the video player.
      return false;
    }

    source.close();
    // Remove the current alert box.
    Navigator.pop(context, true);
    if (message != null) {
      showMessage(message, context);
    }
    return true;
  }

  /// Show a message to the user.
  void showMessage(String message, BuildContext context) {
    print(message);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                textColor: Theme.of(context).buttonColor,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  /// Generate the URI for the API.
  Uri generateUri(String path, [Map<String, String> query]) {
    return _serverUri.replace(path: path, queryParameters: query);
  }

  /// Format a TV/Movie title.
  ///
  /// If a [seasonNumber] and [episodeNumber] is specified (not null), it formats
  /// the title as "Title S01E01".
  /// However if only a [releaseDate] is specified, it's formatted as "Title (yyyy)".
  ///
  /// The [releaseDate] should be an ISO 8601 string and is normally in
  /// the format yyyy-mm-dd.
  String formatTitle(String title,
      [String releaseDate, seasonNumber, episodeNumber]) {
    var buffer = new StringBuffer(title);
    if (seasonNumber != null && episodeNumber != null) {
      buffer.write(' S');
      buffer.write(seasonNumber.toString().padLeft(2, '0'));
      buffer.write('E');
      buffer.write(episodeNumber.toString().padLeft(2, '0'));
    } else if (releaseDate != null) {
      buffer.write(' (');
      buffer
          .write(new DateFormat.y("en_US").format(DateTime.parse(releaseDate)));
      buffer.write(' )');
    }
    return buffer.toString();
  }

  /// Open a video link.
  Future<MaterialPageRoute> openVideo(
      String title, String url, String mimeType, BuildContext context) {
    print("received url: $url");
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CPlayer(
                  title: title,
                  url: url,
                  mimeType: mimeType,
                )));
  }

  /// Whether or not to use a client-side server.
  Future<bool> useClientServer() async {
    await _getSharedPreferences();
    if (_clientSideVendorDelegate == null) {
      // There's no delegate, so use the server.
      return false;
    }
    return _sharedPreferences.getBool('useClientSideResolver') ?? false;
  }

  Future<SharedPreferences> _getSharedPreferences() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    return _sharedPreferences;
  }

  Future<String> _getUserAgent() async {
    return FlutterUserAgent.webViewUserAgent;
  }

  @override
  bool get supportsClientSideResolver {
    return _clientSideVendorDelegate != null;
  }

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    final String payloadPart = parts[1];

    /// Decode the payload
    String output = payloadPart.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    final payload = utf8.decode(base64Url.decode(output));
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid payload');
    }

    return payloadMap;
  }

  ///
  /// Generate a [length] character IV to use with the Salsa20 encoder.
  String _generateIv({length = 8}) {
    var rand = new Random();
    var codeUnits = new List.generate(length, (index) {
      // Alphabets (lower and upper case).
      var start = rand.nextBool() ? 65 : 97;
      return start + rand.nextInt(25);
    });

    return new String.fromCharCodes(codeUnits);
  }
}
