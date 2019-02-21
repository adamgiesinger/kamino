import 'package:flutter/material.dart';
import 'package:kamino/animation/transition.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/trakt.dart' as trakt;
import 'package:kamino/view/settings/page.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:kamino/view/settings/settings_prefs.dart' as settingsPref;

class ExtensionsSettingsPage extends SettingsPage {
  ExtensionsSettingsPage() : super(
      title: "Extensions",
      pageState: ExtensionsSettingsPageState()
  );
}

class ExtensionsSettingsPageState extends SettingsPageState {

  List<String> _traktCred;

  @override
  void initState(){
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
    var traktConnected = _traktCred != null && _traktCred.length == 3;

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      children: <Widget>[

        Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          elevation: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                isThreeLine: true,
                leading: SvgPicture.asset("assets/icons/trakt.svg", height: 36, width: 36, color: const Color(0xFFED1C24)),
                title: Text('Trakt.tv'),
                subtitle: Text("Automatically track what you're watching, synchronise playlists across devices and more..."),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText('Sync'),
                      onPressed: (traktConnected) ? (){
                        trakt.synchronize(context, _traktCred);
                      } : null,
                    ),
                    !traktConnected ?
                      // Trakt account is not linked: show connect option
                      FlatButton(
                        textColor: Theme.of(context).primaryTextTheme.body1.color,
                        child: TitleText('Connect'),
                        onPressed: () {
                          Navigator.push(context, SlideRightRoute(
                              builder: (_ctx) => trakt.TraktAuth(context: _ctx)
                          )).then((var authCode) {
                            trakt.authUser(context, _traktCred, authCode).then((_traktCred) async {
                              setState(() {
                                this._traktCred = _traktCred;
                              });
                            });
                          });
                        },
                      ) :
                    // Trakt account is linked: show disconnect option
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText('Disconnect'),
                      onPressed: () async {
                        // TODO: Show disconnecting dialog
                        if(await trakt.deauthUser(context, _traktCred)){
                          setState(() {
                            _traktCred = [];
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          elevation: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                isThreeLine: true,
                leading: SvgPicture.asset("assets/icons/realdebrid.svg", height: 36, width: 36, color: const Color(0xFF78BB6F)),
                title: Text('Real-Debrid'),
                subtitle: Text("Real-Debrid is an unrestricted downloader that allows you to quickly download files hosted on the Internet."),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText('Coming Soon'),
                      onPressed: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

}