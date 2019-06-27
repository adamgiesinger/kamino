import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamino/ui/interface.dart';
import 'package:kamino/ui/loading.dart';
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
    String url = "$REAL_DEBRID_OAUTH_ENDPOINT/device/code?client_id=$CLIENT_ID&new_credentials=yes";
    http.Response response = await http.get(url);
    Map data = json.decode(response.body);

    // If the authentication code is null, the user probably exited the
    // authentication manually, but let's show a dialog to be safe.
    if (data["user_code"] == null) {
      Interface.showSnackbar(S.of(context).appname_was_unable_to_authenticate_with_real_debrid(appName), context: context, backgroundColor: Colors.red);
      return false;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => new RealDebridAuthenticator(oauthData: data),
      )
    );

    if (result != null && result["access_token"] != null){
      RealDebridCredentials rdCredentials = new RealDebridCredentials.named(
        accessToken: result["access_token"],
        refreshToken: result["refresh_token"],
        expiryDate: DateTime.now().add(new Duration(seconds: result["expires_in"] - REAL_DEBRID_REFRESH_OFFSET)).toString()
      );

      await Settings.setRdCredentials(rdCredentials);
      if(shouldShowSnackbar) Interface.showSnackbar(S.of(context).connected_real_debrid_account, context: context, backgroundColor: Colors.green);
      return true;
    }

    Interface.showSnackbar(S.of(context).appname_was_unable_to_authenticate_with_real_debrid(appName), context: context, backgroundColor: Colors.red);
    return false;
  }

  ///
  /// This method removes the user's credentials.
  ///
  static Future<void> deauthenticate(BuildContext context, { bool shouldShowSnackbar = false }) async {
    await Settings.setRdCredentials(RealDebridCredentials.unauthenticated());
    if(shouldShowSnackbar) Interface.showSnackbar(S.of(context).disconnected_real_debrid_account, context: context, backgroundColor: Colors.red);
  }

  static Future<RealDebridUser> getUserInfo() async {
    await RealDebrid.validateToken();

    RealDebridCredentials rdCredentials = await Settings.rdCredentials;
    Map<String, String> userHeader = {'Authorization': 'Bearer ' + rdCredentials.accessToken};

    http.Response userDataResponse = await http.get(
      REAL_DEBRID_API_ENDPOINT + "/user",
      headers: userHeader
    );

    if (userDataResponse.statusCode == 200) {
      // Get Real-Debrid user information.
      return RealDebridUser.fromJSON(json.decode(userDataResponse.body));
    }

    return null;
  }

  /// IT SEEMS WE DO NOT HAVE ACCESS TO THIS METHOD.
  static Future<bool> convertFidelityPoints(BuildContext context, { bool shouldShowSnackbar = true }) async {
    throw new Exception("Unimplemented method. [We do not have access to this API method.]");
    /*await RealDebrid.validateToken();

    RealDebridCredentials rdCredentials = await Settings.rdCredentials;
    Map<String, String> userHeader = {'Authorization': 'Bearer ' + rdCredentials.accessToken};

    http.Response convertPointsResponse = await http.post(
        REAL_DEBRID_API_ENDPOINT + "/settings/convertPoints",
        headers: userHeader
    );

    print(convertPointsResponse.statusCode);
    print(convertPointsResponse.body);

    return false;*/
  }

  ///
  /// This will check whether or not a user is authenticated with the
  /// RD API.
  ///
  static Future<bool> isAuthenticated() async {
    RealDebridCredentials rdCredentials = await Settings.rdCredentials;
    return rdCredentials != null && rdCredentials.isValid();
  }

  static Future<Map> _getSecret(String device_code) async {
    String url = REAL_DEBRID_OAUTH_ENDPOINT + "/device"
        "/credentials?client_id=$CLIENT_ID&code=$device_code";

    http.Response res = await http.get(url);

    Map data = json.decode(res.body);

    List<String> rdClientInfo = [data["client_id"], data["client_secret"]];
    Settings.$_rdClientInfo = rdClientInfo;

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
    RealDebridCredentials rdCredentials = await Settings.rdCredentials;
    List<String> rdClientInfo = await Settings.$_rdClientInfo;

    Map body = {
      "grant_type": "http://oauth.net/grant_type/device/1.0",
      "client_id": rdClientInfo[0],
      "client_secret": rdClientInfo[1],
      "code": rdCredentials.refreshToken
    };

    http.Response res = await http.post(url, body: body);

    if (res.statusCode == 200) {
      Map result = json.decode(res.body);

      RealDebridCredentials credentials = new RealDebridCredentials.named(
        accessToken: result["access_token"],
        refreshToken: result["refresh_token"],
        expiryDate: DateTime.now().add(new Duration(seconds: result["expires_in"] - REAL_DEBRID_REFRESH_OFFSET)).toString()
      );
      await Settings.setRdCredentials(credentials);

      return true;
    }

    return false;
  }

  static Future<Map<String, dynamic>> unrestrictLink(String link) async {
    RealDebridCredentials rdCredentials = await Settings.rdCredentials;
    Map<String, String> userHeader = {'Authorization': 'Bearer ' + rdCredentials.accessToken};

    http.Response _StreamLinkRes = await http
        .post(REAL_DEBRID_API_ENDPOINT + "/unrestrict/link", headers: userHeader, body: {"link": link});

    if (_StreamLinkRes.statusCode == 200) {
      //get the derestricted stream response
      return json.decode(_StreamLinkRes.body);
    }

    return null;
  }

  static Future<void> validateToken() async {
    RealDebridCredentials rdCredentials = await Settings.rdCredentials;
    bool tokenCheck = DateTime.now().isBefore(DateTime.parse(rdCredentials.expiryDate));

    if (!tokenCheck) {
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
  StreamSubscription<String> _onUrlChanged;

  String targetUrl;
  bool isAllowed = false;

  @override
  void initState() {
    flutterWebviewPlugin.close();

    _prepare().then((String target) {
        if(mounted) setState(() {
          targetUrl = target;
        });
    });

    // Listen for done via URL change.
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      // Execute a simple script to 'disarm' the Real-Debrid link
      await flutterWebviewPlugin.evalJavascript(
        "document.querySelectorAll(\"a[href='/']\").forEach((element) => element.onclick = (e) => e.preventDefault());"
      );

      // Check if the application has been authorized (so done state can be set).
      this.isAllowed = await flutterWebviewPlugin.evalJavascript('document.body.innerHTML.indexOf("Application allowed") !== -1') == "true";
      if(mounted) setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: targetUrl != null ? WebviewScaffold(
        url: targetUrl,
        userAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36",
        clearCache: true,
        clearCookies: true,
        appBar: AppBar(
          leading: isAllowed ? Container() : null,
          title: TitleText(S.of(context).real_debrid_authenticator),
          centerTitle: true,
          elevation: 8.0,
          backgroundColor: Theme.of(context).cardColor,
          actions: <Widget>[
            isAllowed ? FlatButton(
              child: Text(S.of(context).done.toUpperCase()),
              onPressed: () async {
                if(this.context != null && mounted) Navigator.pop(
                  this.context,
                  await RealDebrid.getToken(widget.oauthData["device_code"])
                );
              },
            ) : Container()
          ],
        ),
      ) : Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: TitleText(S.of(context).real_debrid_authenticator),
          centerTitle: true,
          elevation: 8.0,
          backgroundColor: Theme.of(context).cardColor,
        ),
        body: Center(
          child: ApolloLoadingSpinner(),
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

class RealDebridUser {

  int id;
  String username;
  String email;
  int points;
  String locale;
  String avatar;
  String type;
  int premiumSecondsRemaining;
  DateTime expirationDate;

  RealDebridUser.fromJSON(Map json) :
    id = json['id'],
    username = json['username'],
    email = json['email'],
    points = json['points'],
    locale = json['locale'],
    avatar = json['avatar'],
    type = json['type'],
    premiumSecondsRemaining = json['premium'],
    expirationDate = DateTime.parse(json['expiration']);

  bool isPremium(){
    return this.type.toLowerCase() == "premium";
  }

}