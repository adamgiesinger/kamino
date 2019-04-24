import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/interface/settings/page.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/util/settings.dart';
import 'package:package_info/package_info.dart';

class PlaybackSettingsPage extends SettingsPage {

  static const String BUILT_IN_PLAYER_NAME = "CPlayer";

  PlaybackSettingsPage(BuildContext context) : super(
    title: S.of(context).playback,
    pageState: PlaybackSettingsPageState(),
  );

}

const platform = const MethodChannel('xyz.apollotv.kamino/playThirdParty');

class PlaybackSettingsPageState extends SettingsPageState {

  PlayerSettings playerSettings = PlayerSettings.defaultPlayer();

  @override
  void initState(){
    (() async {
      playerSettings = await Settings.playerInfo;
      setState((){});
    })();
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context){
    return ListView(
      physics: widget.isPartial ? NeverScrollableScrollPhysics() : null,
      shrinkWrap: widget.isPartial ? true : false,
      children: <Widget>[
        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            leading: Icon(Icons.play_circle_filled),
            title: TitleText("Change Player"),
            subtitle: Text(
              // CPlayer is hardcoded. Do not translate it.
              playerSettings.isValid() ? playerSettings.name : "${PlaybackSettingsPage.BUILT_IN_PLAYER_NAME} (Default)"
            ),
            onTap: () => _showPlayerSelectDialog(context),
          ),
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            leading: Icon(Icons.cast),
            title: TitleText("Cast Settings"),
            subtitle: Text("Coming Soon"),
            onTap: (){
              showDialog(context: context, builder: (BuildContext context){
                return AlertDialog(
                  title: TitleText("Not yet implemented..."),
                  content: Text("This feature has not yet been implemented."),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(S.of(context).okay),
                      textColor: Theme.of(context).primaryColor,
                    )
                  ],
                );
              });
            },
          ),
        ),
      ]
    );
  }

  _showPlayerSelectDialog(BuildContext context) async {
    PackageInfo packageInfo;

    Future<dynamic> _loadPlayerData = Future(() async {
      packageInfo = await PackageInfo.fromPlatform();
      return jsonDecode(await platform.invokeMethod('list'));
    });

    showDialog(
        context: context,
        builder: (_) {
          return SimpleDialog(
            title: TitleText("Select Player..."),
            children: <Widget>[
              Container(
                  height: 250,
                  width: 300,
                  child: FutureBuilder(future: _loadPlayerData, builder: (_, AsyncSnapshot<dynamic> snapshot) {
                    if(snapshot.connectionState != ConnectionState.done) {
                      return Container(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor
                          ),
                        ),
                      );
                    }

                    return Scrollbar(
                      child: ListView.builder(itemBuilder: (BuildContext context, int index) {
                        // Add entry for built in player
                        if(index == 0){
                          return ListTile(
                            isThreeLine: true,
                            title: TitleText('CPlayer (Default)'),
                            subtitle: Text("ApolloTV built-in player.\nVersion ${packageInfo.version}"),
                            leading: ClipRRect(
                                borderRadius: BorderRadius.circular(48),
                                child: Image(
                                  image: AssetImage("assets/images/logo.png"),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  width: 48,
                                  height: 48,
                                )
                            ),
                            enabled: true,
                            onTap: () async {
                              setState(() {
                                playerSettings = PlayerSettings.defaultPlayer();
                              });
                              await Settings.setPlayerInfo(playerSettings);

                              Navigator.of(context).pop();
                            },
                          );
                        }

                        index--;
                        return ListTile(
                          title: TitleText(snapshot.data[index]['name']),
                          subtitle: Text("Version ${snapshot.data[index]['version']}"),
                          leading: ClipRRect(
                              borderRadius: BorderRadius.circular(48),
                              child: Image(
                                image: MemoryImage(
                                    Base64Decoder().convert(snapshot.data[index]['icon'].replaceAll('\n', ''))
                                ),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                width: 48,
                                height: 48,
                              )
                          ),
                          enabled: true,
                          onTap: () async {
                            setState(() {
                              playerSettings = new PlayerSettings([
                                snapshot.data[index]['activity'],
                                snapshot.data[index]['package'],
                                snapshot.data[index]['name']
                              ]);
                            });

                            await Settings.setPlayerInfo(playerSettings);
                            Navigator.of(context).pop();
                          },
                        );
                      }, itemCount: snapshot.data.length + 1, shrinkWrap: true),
                    );
                  })
              )
            ]
          );
        }
    );
  }

}