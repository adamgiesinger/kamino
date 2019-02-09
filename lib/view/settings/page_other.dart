import 'dart:io';
import 'package:http/http.dart' as http;

import 'dart:convert' as Convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:kamino/animation/transition.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/trakt.dart';
import 'package:kamino/view/settings/page.dart';

import 'package:kamino/view/settings/settings_prefs.dart' as settingsPref;
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherSettingsPage extends SettingsPage {

  OtherSettingsPage() : super(
      title: "Other",
      pageState: OtherSettingsPageState()
  );

}

class OtherSettingsPageState extends SettingsPageState {

  bool _sourceSelection = false;
  bool _expandedSearchValue = false;
  List<String> _traktCred = [];

  PackageInfo _packageInfo = new PackageInfo(
      appName: 'Unknown',
      packageName: 'Unknown',
      version: 'Unknown',
      buildNumber: 'Unknown'
  );

  Future<Null> _fetchPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState(){
    _fetchPackageInfo();

    settingsPref.getBoolPref("expandedSearch").then((data){
      setState(() {
        _expandedSearchValue = data;
      });
    });

    settingsPref.getBoolPref("sourceSelection").then((data){
      setState(() {
        _sourceSelection = data;
      });
    });

    settingsPref.getListPref("traktCredentials").then((data){
      setState(() {
        if (data == null || data == []){
          _traktCred = [];
        } else {
          _traktCred = data;
        }
      });
    });

    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());

    return ListView(
      children: <Widget>[
        Platform.isAndroid ?
          Material(
            color: Theme.of(context).backgroundColor,
            child: ListTile(
              title: TitleText("Check for Updates"),
              enabled: true,
              onTap: () async {

                var otaObject = Convert.jsonDecode((await http.get("https://houston.apollotv.xyz/ota")).body);

                var _alreadyUpToDate = (){
                  showDialog(context: context,
                      builder: (BuildContext _ctx){
                        return AlertDialog(
                          title: TitleText("No updates available"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("You already have the latest version.")
                            ],
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: TitleText("Okay", fontSize: 15),
                              onPressed: () => Navigator.of(context).pop(),
                              textColor: Theme.of(context).primaryColor,
                            )
                          ],
                        );
                      });
                };

                if(otaObject["latest"] == null){
                  _alreadyUpToDate();
                  return;
                }

                otaObject = otaObject["latest"];

                if(int.parse(otaObject["buildNumber"]) > int.parse(_packageInfo.buildNumber)){
                  showDialog(context: context,
                      builder: (BuildContext _ctx){
                        return AlertDialog(
                          title: TitleText("New Update"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TitleText(otaObject["title"]),
                              Container(padding: EdgeInsets.symmetric(vertical: 10)),
                              Text(otaObject["changelog"])
                            ],
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: TitleText("Cancel", fontSize: 15),
                              onPressed: () => Navigator.of(context).pop(),
                              textColor: Theme.of(context).primaryColor,
                            ),
                            FlatButton(
                              child: TitleText("Install", fontSize: 15),
                              onPressed: (){
                                _launchURL("https://houston.apollotv.xyz/ota/${otaObject["_id"]}");
                                Navigator.of(context).pop();
                              },
                              textColor: Theme.of(context).primaryColor,
                            )
                          ],
                        );
                      });
                }else{
                  _alreadyUpToDate();
                }

              },
            ),
          ) :
            Container(),

        Material(
          color: Theme.of(context).backgroundColor,
          child: CheckboxListTile(
            isThreeLine: true,
            activeColor: Theme.of(context).primaryColor,
            value: _sourceSelection,
            title: TitleText("Manually Select Sources"),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Shows a dialog with a list of discovered sources instead of automatically choosing one.",
                style: TextStyle(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            onChanged: (value){
              if (value != _sourceSelection){
                settingsPref.saveBoolPref("sourceSelection", value).then((data){
                  setState(() {
                    _sourceSelection = data;
                  });
                });
              }
            },
          ),
        ),

        Material(
          color: Theme.of(context).backgroundColor,
          child: CheckboxListTile(
            isThreeLine: true,
            activeColor: Theme.of(context).primaryColor,
            value: _expandedSearchValue,
            title: TitleText("Detailed Content Information"),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Replaces the grid of posters with a list of more detailed cards on search and overview pages.",
                style: TextStyle(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            onChanged: (value){
              if (value != _expandedSearchValue){
                settingsPref.saveBoolPref("expandedSearch", value).then((data){
                  setState(() {
                    _expandedSearchValue = data;
                  });
                });
              }
            },
          ),
        ),

        Material(
          color: Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText("Clear History"),
            subtitle: Text("Does what the name says..."),
            enabled: true,
            onTap: (){
              settingsPref.saveListPref("searchHistory", []);
              Scaffold.of(context).showSnackBar(
                  new SnackBar(content: Text("All Done!",
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: "GlacialIndifference",
                        fontSize: 17.0
                    ),),
                    backgroundColor: Colors.green,
                    duration: new Duration(milliseconds: 600),
                  )
              );
            },
          ),
        ),

        _traktCred.length != 3 ? Material(
          color: Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText("Sign In to Trakt"),
            enabled: true,
            onTap: () async {

              //final value = await
              Navigator.push(context, SlideRightRoute(
                  builder: (context) => new TraktAuth()
              )).then((var authCode){
                _authUser(context, authCode);
              });

            },
          ),
        ) : Material(
          color: Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText("Sign Out of Trakt"),
            enabled: true,
            onTap: () async {

              Map body = {
                'token': _traktCred[0],
                'client_id': appState.getVendorConfigs()[0].traktCredentials.id,
                'client_secret': appState.getVendorConfigs()[0].traktCredentials.secret
              };

              String url = "https://api.trakt.tv/oauth/revoke";
              Response res = await post(url, body: body);

              if (res.statusCode == 200){

                setState(() {
                  _traktCred = [];
                });

                settingsPref.saveListPref("traktCredentials", []);

                Scaffold.of(context).showSnackBar(
                    new SnackBar(content: Text("All Done!",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "GlacialIndifference",
                          fontSize: 17.0
                      ),),
                      backgroundColor: Colors.green,
                    )
                );
              }

            },
          ),
        ),

        Material(
          color: Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText("Sync Trakt Collection"),
            subtitle: Text("Send new data to trakt and retrieve existing data",
              overflow: TextOverflow.ellipsis,
            ),
            enabled: _traktCred.length == 3 ? true : false,
            onTap: (){
              _trakSyncLogic(context);
            },
          ),
        ),

      ],
    );
  }

  //Trakt authentication logic
  void _authUser(BuildContext context, String code) async{

    KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());

    if (code == null){
      //Trakt auth has failed

      _dialogGenerator(
          "Authentication Unsuccessful",
          "Kamino was unable to authenticate with Trakt.",
          context,
          true
      );

    } else {
      //continue with authentication process

      /*
      _dialogGenerator(
          "Processing",
          "Authenticating Trakt credentials, please wait...",
          context,
          false
      );
      */

      //exchange the code for an access token
      String url = "https://api.trakt.tv/oauth/token";

      Map _body = {
        "code": code,
        "client_id": appState.getVendorConfigs()[0].traktCredentials.id,
        "client_secret": appState.getVendorConfigs()[0].traktCredentials.secret,
        "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
        "grant_type": "authorization_code"
      };

      Response res = await post(url, body: _body);

      if (res.statusCode == 200){

        Map _data = json.decode(res.body);

        //save the response to shared pref
        /*

        key - trakt Credentials
        0 - access token
        1 - refresh token
        2 - expiry date
        */

        List<String> temp = [
          _data["access_token"],
          _data["refresh_token"],

          //date in 3 months, used to determine if token needs to be refreshed
          DateTime.now().add(new Duration(days: 84)).toString()
        ];

        settingsPref.saveListPref("traktCredentials", temp);

        //success dialog
        setState(() {
          _traktCred = temp;
        });

        _dialogGenerator("Success", "You're all set", context, true);

      } else {

        //show error message
        _dialogGenerator(
            "Authentication Failed",
            "Error ${res.statusCode} \n Please Try Again",
            context,
            true
        );
      }
    }
  }

  void _dialogGenerator(String title, String body, BuildContext context, bool dismiss){

    TextStyle _glacialFont = new TextStyle(
        fontSize: 18.0,
        fontFamily: "GlacialIndifference",
        color: Colors.white
    );

    showDialog(
        context: context,
        barrierDismissible: dismiss,
        builder: (_){
          return AlertDialog(
            title: TitleText(title),
            content: Text(body,
              style: _glacialFont,
            ),
            actions: <Widget>[
              Center(
                child: FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Okay",
                    style: _glacialFont,
                  ),
                ),
              )
            ],
            //backgroundColor: Theme.of(context).cardColor,
          );
        }
    );
  }

  void _trakSyncLogic(BuildContext context) async {

    TextStyle _glacialFont = new TextStyle(
        fontSize: 17.0,
        fontFamily: "GlacialIndifference",
        color: Colors.white
    );

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_){
          return AlertDialog(
            title: TitleText("Trakt Synchronization..."),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Please wait while we synchronize your favorites with Trakt. " +
                      "This dialog will close automatically when synchronization is complete.",
                    style: _glacialFont,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //backgroundColor: Theme.of(context).cardColor,
          );
        }
    );

    String pullStatus = await getCollection(_traktCred, context);
    Future.delayed(new Duration(seconds: 4));
    List<int> saveStatus = await addFavToTrakt(_traktCred, context);

    Navigator.pop(context);
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}
