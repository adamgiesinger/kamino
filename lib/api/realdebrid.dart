import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamino/ui/interface.dart';
import 'package:kamino/util/settings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/elements.dart';

class RealDebrid {

  static const REAL_DEBRID_OAUTH_ENDPOINT = "https://api.real-debrid.com/oauth/v2";
  static const REAL_DEBRID_API_ENDPOINT = "https://api.real-debrid.com/rest/1.0";
  static const REAL_DEBRID_REFRESH_OFFSET = 300;

  // See https://api.real-debrid.com/#api_authentication
  // ('Authentication for applications' header)
  static const CLIENT_ID = "X245A4XAIBGVM";

  ///
  /// This method authenticates the user with the RD API.
  ///
  static Future<bool> authenticate(BuildContext context, { bool shouldShowSnackbar = false }) async {
    // Make a request to the API with the code to get oauth credentials.
    String url = REAL_DEBRID_OAUTH_ENDPOINT + "/device"
        "/code?client_id=$CLIENT_ID&new_credentials=yes";
    http.Response response = await http.get(url);
    Map data = json.decode(response.body);

    // If the authentication code is null, the user probably exited the
    // authentication manually, but let's show a dialog to be safe.
    if (data["user_code"] == null) {
      Interface.showSimpleErrorDialog(
          context,
          title: S.of(context).authentication_unsuccessful,
          reason: S.of(context).appname_was_unable_to_authenticate_with_real_debrid(appName)
      );

      return false;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => new RealDebridAuthenticator(oauthData: data),
      )
    );

    if (result["access_token"] != null){
      List<String> _cred = [result["access_token"],
      result["refresh_token"],
      DateTime.now().add(new Duration(seconds: result["expires_in"] - REAL_DEBRID_REFRESH_OFFSET)).toString()];

      Settings.rdCredentials = _cred;
      if(shouldShowSnackbar) Interface.showSnackbar(S.of(context).connected_real_debrid_account, context: context, backgroundColor: Colors.green);
      return true;
    }

    Interface.showSimpleErrorDialog(
        context,
        title: S.of(context).authentication_unsuccessful,
        reason: S.of(context).appname_was_unable_to_authenticate_with_real_debrid(appName) +
          "\n\nError ${response.statusCode.toString()}"
    );
    return false;
  }

  ///
  /// This method removes the user's credentials.
  ///
  static Future<void> deauthenticate(BuildContext context, { bool shouldShowSnackbar = false }) async {
    Settings.rdCredentials = [];
    if(shouldShowSnackbar) Interface.showSnackbar(S.of(context).disconnected_real_debrid_account, context: context, backgroundColor: Colors.red);
  }

  ///
  /// This will check whether or not a user is authenticated with the
  /// RD API.
  ///
  static Future<bool> isAuthenticated() async {
    var _rdCred = await Settings.rdCredentials;
    return _rdCred != null && _rdCred.length == 3;
  }

  static Future<Map> _getSecret(String device_code) async {
    String url = REAL_DEBRID_OAUTH_ENDPOINT + "/device"
        "/credentials?client_id=$CLIENT_ID&code=$device_code";

    http.Response res = await http.get(url);

    Map data = json.decode(res.body);

    List<String> _rdClientInfo = [data["client_id"], data["client_secret"]];

    Settings.rdClientInfo = _rdClientInfo;

    return data;
  }

  static Future<Map> getToken(String device_code) async {
    Map data = await _getSecret(device_code);

    if (data["client_id"] != null || data["client_secret"] != null) {
      //get the token using the client id and client secret
      String url = REAL_DEBRID_OAUTH_ENDPOINT + "/token";

      Map body = {
        "client_id": data["client_id"],
        "client_secret": data["client_secret"],
        "code": device_code,
        "grant_type": "http://oauth.net/grant_type/device/1.0"
      };

      http.Response res = await http.post(url, body: body);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    }

    return {"access_token": null};
  }

  static Future<bool> _refreshToken() async {
    String url = REAL_DEBRID_OAUTH_ENDPOINT + "/token";

    //get rd credentials
    List<String> _rdCred = [];
    List<String> _rdIDSecret = [];

    await ((Settings.rdCredentials) as Future).then((data) {
      _rdCred = data;
    });

    await ((Settings.rdClientInfo) as Future).then((data) {
      _rdIDSecret = data;
    });

    Map body = {
      "client_id": _rdIDSecret[0],
      "grant_type": "http://oauth.net/grant_type/device/1.0",
      "client_secret": _rdIDSecret[1],
      "code": _rdCred[1]
    };

    http.Response res = await http.post(url, body: body);

    if (res.statusCode == 200) {
      Map result = json.decode(res.body);

      List<String> _cred = [
        result["access_token"],
        result["refresh_token"],
        DateTime.now().add(new Duration(seconds: result["expires_in"] - REAL_DEBRID_REFRESH_OFFSET)).toString()
      ];

      Settings.rdCredentials = _cred;

      return true;
    }

    return false;
  }

  static Future<Map<String, dynamic>> unrestrictLink(String link) async {
    List<String> _rdCred = [];

    await ((Settings.rdCredentials) as Future).then((data) {
      _rdCred = data;
    });

    Map<String, String> userHeader = {'Authorization': 'Bearer ' + _rdCred[0]};

    http.Response _StreamLinkRes = await http
        .post(REAL_DEBRID_API_ENDPOINT + "/unrestrict/link", headers: userHeader, body: {"link": link});

    if (_StreamLinkRes.statusCode == 200) {
      //get the derestricted stream response
      return json.decode(_StreamLinkRes.body);
    }

    return null;
  }

  static Future<bool> validateToken() async {
    List<String> _rdCred = [];

    await ((Settings.rdCredentials) as Future).then((data) {
      _rdCred = data;
    });

    bool tokenCheck = DateTime.now().isBefore(DateTime.parse(_rdCred[2]));

    if (!tokenCheck) {
      //refresh the token
      return await _refreshToken();
    }
  }
}

class RealDebridAuthenticator extends StatefulWidget {
  final Map oauthData;

  RealDebridAuthenticator({
    this.oauthData
  });

  @override
  _RealDebridAuthenticatorState createState() => new _RealDebridAuthenticatorState();
}

class _RealDebridAuthenticatorState extends State<RealDebridAuthenticator> {

  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  String _targetUrl;

  @override
  void initState() {
    flutterWebviewPlugin.close();

    _prepare().then((String target) {
        if(mounted) setState(() {
          _targetUrl = target;
        });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            this.context,
            await RealDebrid.getToken(widget.oauthData["device_code"])
        );
        return false;
      },
      child: _targetUrl != null ? WebviewScaffold(
        url: _targetUrl,
        userAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36",
        clearCache: true,
        clearCookies: true,
        appBar: AppBar(
          title: TitleText("Real Debrid Authenticator"),
          centerTitle: true,
          elevation: 8.0,
          backgroundColor: Theme.of(context).cardColor,
        ),
      ) : Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: TitleText("Real Debrid Authenticator"),
          centerTitle: true,
          elevation: 8.0,
          backgroundColor: Theme.of(context).cardColor,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<String> _prepare() async {
    http.Response response = await http.post(
      widget.oauthData["verification_url"],
      headers: {
        'Content-Type': "application/x-www-form-urlencoded"
      },
      body: "usercode=${widget.oauthData["user_code"]}&action=Continue"
    );

    return response.headers['location'];
  }

  @override
  void dispose() {
    flutterWebviewPlugin.dispose();
    super.dispose();
  }
}