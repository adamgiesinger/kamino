import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamino/ui/elements.dart';
import 'package:kamino/util/settings.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

const _client_id = "X245A4XAIBGVM";
const url = "https://api.real-debrid.com/rest/1.0/";

// TODO: pull this from RD API
const supportedHosts = ["openload.com", "streamango.com"];

class RealDebrid extends StatefulWidget {
  final Map oauth_data;

  RealDebrid({this.oauth_data});

  @override
  _RealDebridState createState() => new _RealDebridState();
}

class _RealDebridState extends State<RealDebrid> {
  // Instance of WebView plugin
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    flutterWebviewPlugin.close();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
            this.context, await getToken(widget.oauth_data["device_code"]));

        return true;
      },
      child: WebviewScaffold(
        url: widget.oauth_data["verification_url"],
        userAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36",
        clearCache: true,
        clearCookies: true,
        appBar: AppBar(
          title: TitleText("Auth Code: ${widget.oauth_data["user_code"]}"),
          centerTitle: true,
          elevation: 8.0,
          backgroundColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterWebviewPlugin.dispose();
    super.dispose();
  }
}

Future<bool> userHasRD() async {
  var _rdCred = await Settings.rdCredentials;
  return _rdCred != null && _rdCred.length == 3;
}

bool isProviderSupported(String url) {
  for (var host in supportedHosts) {
    if(url.contains(host))
      return true;
  }
  return false;
}

Future<Map> getOAuthInfo() async {
  String url = "https://api.real-debrid.com/oauth/v2/device"
      "/code?client_id=$_client_id&new_credentials=yes";

  http.Response res = await http.get(url);

  print("OAuth api response: ${res.body}..... code ${res.statusCode}");
  return json.decode(res.body);
}

Future<Map> _getSecret(String device_code) async {
  String url = "https://api.real-debrid.com/oauth/v2/device"
      "/credentials?client_id=$_client_id&code=$device_code";

  http.Response res = await http.get(url);
  print("secret api response: ${res.body}..... code ${res.statusCode}");

  Map data = json.decode(res.body);

  List<String> _rdClientInfo = [data["client_id"], data["client_secret"]];

  Settings.rdClientInfo = _rdClientInfo;

  return data;
}

Future<Map> getToken(String device_code) async {
  Map data = await _getSecret(device_code);

  if (data["client_id"] != null || data["client_secret"] != null) {
    //get the token using the client id and client secret
    String url = "https://api.real-debrid.com/oauth/v2/token";

    Map body = {
      "client_id": data["client_id"],
      "client_secret": data["client_secret"],
      "code": device_code,
      "grant_type": "http://oauth.net/grant_type/device/1.0"
    };

    http.Response res = await http.post(url, body: body);

    print("api response code: ${res.statusCode}");

    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
  }

  return {"access_token": null};
}

Future<bool> _refreshToken() async {
  String url = "https://api.real-debrid.com/oauth/v2/token";

  //get rd credentials
  List<String> _rdCred = [];
  List<String> _rdIDSecret = [];

  ((Settings.rdCredentials) as Future).then((data) {
    _rdCred = data;
  });

  ((Settings.rdClientInfo) as Future).then((data) {
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
    print("refreshing token data with ${res.body}");

    List<String> _cred = [
      result["access_token"],
      result["refresh_token"],
      DateTime.now().add(new Duration(seconds: result["expires_in"])).toString()
    ];

    Settings.rdCredentials = _cred;

    return true;
  } else {
    print("refresh token api response: ${res.statusCode}\n${res.body}");
  }

  return false;
}

Future<Map<String, dynamic>> unrestrictLink(String link) async {
  List<String> _rdCred = [];

  await ((Settings.rdCredentials) as Future).then((data) {
    _rdCred = data;
  });

  bool tokenCheck = DateTime.now().isBefore(DateTime.parse(_rdCred[2]));

  print("token check is:  $tokenCheck");

  if (!tokenCheck) {
    //refresh the token
    bool refreshSuccess = await _refreshToken();
    print("refreshing token: $refreshSuccess");

    if (refreshSuccess == false) {
      print("token refresh failed");
      return null;
    }
  }

  Map<String, String> userHeader = {'Authorization': 'Bearer ' + _rdCred[0]};

  http.Response _StreamLinkRes = await http
      .post(url + "unrestrict/link", headers: userHeader, body: {"link": link});

  if (_StreamLinkRes.statusCode == 200) {
    //get the derestricted stream response
    return json.decode(_StreamLinkRes.body);
  }

  return null;
}
