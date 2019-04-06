import 'dart:convert' as Convert;
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/util/settings.dart';
import 'package:kamino/vendor/struct/VendorService.dart';
import 'package:ntp/ntp.dart';

class ClawsVendorService extends VendorService {

  // Settings
  static const bool ALLOW_SOURCE_SELECTION = true;
  static const bool FORCE_TOKEN_REGENERATION = true;

  // Claws information
  final String server;
  final String clawsKey;
  final bool isOfficial;

  ClawsVendorService({
    this.server,
    this.clawsKey,
    this.isOfficial = false
  });

  String _token;

  @override
  Future<bool> authenticate(BuildContext context, {bool force = false}) async {

    /* ATTEMPT TO CONNECT TO SERVER */
    try {
      Response response = await get(server + 'api/v1/status').timeout(Duration(seconds: 10), onTimeout: (){
        Navigator.of(context).pop();
        Interface.showSimpleErrorDialog(
          context,
          title: "Unable to connect...",
          reason: "The request timed out.\n\n(Is your connection too slow?)"
        );
      });

      var status = Convert.jsonDecode(response.body);
    }catch(ex){
      print("Exception whilst determining Claws status: $ex");
      Navigator.of(context).pop();

      Interface.showSimpleErrorDialog(context,
        title: "Unable to connect...",
        reason: isOfficial
        ? "The $appName server is currently offline for server upgrades.\nPlease check the #announcements channel in our Discord server for more information."
          : "Unable to connect to server."
      );
      return false;
    }

    String token = await Settings.clawsToken;
    double tokenSetTime = await Settings.clawsTokenSetTime;

    DateTime now = await NTP.now();
    if(!FORCE_TOKEN_REGENERATION
        && token != null
        && (tokenSetTime + 3600) >= (now.millisecondsSinceEpoch / 1000).floor()
    ){
      print("Attempting to re-use token...");

      // TODO: Check that token is still valid!

      _token = token;
      return true;
    }else{
      var clawsClientHash = await _generateClawsHash(clawsKey, now).timeout(Duration(seconds: 5), onTimeout: () async {
        Interface.showSimpleErrorDialog(context, title: "Unable to connect...", reason: "Authentication timed out.\n\nPlease try again.");
      });

      Response response = await post(
          server + 'api/v1/login',
          body: Convert.jsonEncode({"clientID": clawsClientHash}),
          headers: {"Content-Type": "application/json"}
      ).timeout(Duration(seconds: 10), onTimeout: () async {
        Interface.showSimpleErrorDialog(context, title: "Unable to connect...", reason: "Authentication timed out.\n\nPlease try again.");
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
        Interface.showSimpleErrorDialog(context, title: "Unable to connect...", reason: tokenResponse["message"]);
        return false;
      }
    }
  }

  @override
  Future<void> playMovie(String title, String releaseDate, BuildContext context) {



    return null;
  }

  @override
  Future<void> playTVShow(String title, String releaseDate, int seasonNumber, int episodeNumber, BuildContext context) {



    return null;
  }


  ///////////////////////////////
  /// CLAWS UTILITY FUNCTIONS ///
  ///////////////////////////////

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

}