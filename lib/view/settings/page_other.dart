import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:kamino/animation/transition.dart';
import 'package:kamino/vendor/dist/config/OfficialVendorConfiguration.dart' as vendor;
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/trakt.dart';
import 'package:kamino/view/settings/page.dart';

import 'package:kamino/view/settings/settings_prefs.dart' as settingsPref;

class OtherSettingsPage extends SettingsPage {

  OtherSettingsPage() : super(
      title: "Other",
      pageState: OtherSettingsPageState()
  );

}


class OtherSettingsPageState extends SettingsPageState {

  bool _expandedSearchValue = false;
  List<String> _traktCred = [];

  @override
  void initState(){
    settingsPref.getBoolPref("expandedSearch").then((data){
      setState(() {
        //print("initial expanded search value is $data");
        _expandedSearchValue = data;
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
    return ListView(
      children: <Widget>[
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
            title: TitleText("Login to Trakt"),
            enabled: true,
            onTap: () async {

              //final value = await
              Navigator.push(context, SlideRightRoute(
                  builder: (context) => new TraktAuth()
              )).then((var authCode){

                print("authCode is: $authCode");
                _authUser(context, authCode);

              });

            },
          ),
        ) : Material(
          color: Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText("Sign out of Trakt"),
            enabled: true,
            onTap: () async {

              Map body = {
                'token': _traktCred[0],
                'client_id': vendor.trakt_client_id,
                'client_secret': vendor.trakt_secret
              };

              String url = "https://api.trakt.tv/oauth/revoke";
              Response res = await post(url, body: body);

              if (res.statusCode == 200){

                print("revoke returned: ${res.body}");
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
        )

      ],
    );
  }

  //Trakt authentication logic
  void _authUser(BuildContext context, String code) async{

    if (code == null){
      //Trakt auth has failed

      _dialogGenerator(
          "Authentication Unsuccessful",
          "Unable to authenticate trakt account please try again",
          context,
          true
      );

    } else {
      //continue with authentication process

      print("received code: $code");

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
        "client_id": vendor.trakt_client_id,
        "client_secret": vendor.trakt_secret,
        "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
        "grant_type": "authorization_code"
      };

      Response res = await post(url, body: _body);

      if (res.statusCode == 200){

        Map _data = json.decode(res.body);

        print("api returned: $_data");

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
            title: TitleText("Syncing with Trakt"),
            content: Container(
              height: 160.0,
              child: Column(
                children: <Widget>[
                  Text("Please wait while we synchronise your favorites with"
                      " Trakt, dialog will close when sync is complete",
                    style: _glacialFont,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.deepPurpleAccent,
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

    //String pullStatus = await getCollection(_traktCred);
    //Future.delayed(new Duration(seconds: 2));
    String saveStatus = await addFavToTrakt(_traktCred);

    Navigator.pop(context);
  }

}
