import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_parallax/flutter_parallax.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/interface/settings/page_advanced.dart';
import 'package:kamino/interface/settings/page_extensions.dart';
import 'package:package_info/package_info.dart';

import 'package:kamino/main.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/animation/transition.dart';
import 'package:kamino/interface/settings/utils/ota.dart' as OTA;

import 'package:kamino/interface/settings/page_appearance.dart';
import 'package:kamino/interface/settings/page_other.dart';

class SettingsView extends StatefulWidget {

  @override
  _SettingsViewState createState() => _SettingsViewState();

  // DO NOT TRANSLATE!
  static final buildTypes = [
    "Pre-Release",
    "Beta",
    "Release Candidate",
    "Stable"
  ];

}

class _SettingsViewState extends State<SettingsView> {

  List<String> _contributors;
  
  PackageInfo _packageInfo = new PackageInfo(
      appName: 'Unknown',
      packageName: 'Unknown',
      version: 'Unknown',
      buildNumber: 'Unknown'
  );

  @override
  void initState() {
    _fetchPackageInfo();
    //_fetchContributors();

    super.initState();
  }

  Future<Null> _fetchPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<Null> _fetchContributors() async {
    String content = await rootBundle.loadString("assets/contributors.txt");
    List<String> contributors = new List();

    for(String entry in content.split("\n")){
      if(entry != "") {
        contributors.add(entry);
      }
    }

    setState(() {
      _contributors = contributors;
    });
  }

  int versionTapCount = 0;

  @override
  Widget build(BuildContext context) {

    KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());

    return Scaffold(
        appBar: AppBar(
          title: TitleText(S.of(context).settings),

          backgroundColor: Theme.of(context).backgroundColor,

          // Center title
          centerTitle: true,
        ),

        // The Builder is used to access the parent Scaffold.
        body: Builder(builder: (BuildContext context){
          return Container(
              color: Theme.of(context).backgroundColor,
              child: new ListView(

                  children: <Widget>[

                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 250,
                      child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Parallax.inside(
                                mainAxisExtent: 250.0,
                                child: new Image.asset(
                                  "assets/images/logo_background.png",
                                  fit: BoxFit.cover,
                                )
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[

                                    Container(
                                        padding: EdgeInsets.only(bottom: 5),
                                        child: Image.asset("assets/images/logo_foreground_lg.png", width: 64, height: 64)
                                    ),

                                    TitleText("$appName v${_packageInfo.version}", fontSize: 24, textColor: Colors.white),

                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 5),
                                      child: Text("${appState.getVendorConfigs()[0].getName()} ${_getBuildType()} Build \u2022 ${_packageInfo.buildNumber}", style: TextStyle(
                                          color: Colors.white
                                      )),
                                    ),

                                    Platform.isAndroid ? Container(padding: EdgeInsets.only(top: 10), child: RaisedButton(
                                      child: Text(S.of(context).check_for_updates),
                                      onPressed: () => OTA.updateApp(context, false)
                                    )) : Container()

                                  ]
                              ),
                            )
                          ]
                      ),
                    ),

                    Container(padding: EdgeInsets.symmetric(vertical: 10)),

                    /*Material(
                    color: Theme.of(context).backgroundColor,
                    child: ListTile(
                      title: TitleText("About $appName"),
                      leading: new Image.asset("assets/images/logo.png", width: 36, height: 36),
                      enabled: true,
                      subtitle: Text("v${_packageInfo.version} (Build  "),
                      onTap: (){
                        _tapCount++;

                        if(_tapCount == 10){
                          Scaffold.of(context).showSnackBar(SnackBar(
                            //content: Text('"Every pair of jeans are skinny jeans if you\'re thicc enough" - Gagnef 12,016HE')
                            content: Text("(\\xE2\\x9D\\xA4) E.D.")
                          ));

                          _tapCount = 0;
                        }
                      }
                    ),
                  ),*/

                    Container(
                      margin: EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SubtitleText(
                            S.of(context).make_appname_yours(appName.toUpperCase()),
                            padding: EdgeInsets.zero,
                          )
                        ],
                      )
                    ),

                    Material(
                      color: Theme.of(context).backgroundColor,
                      child: ListTile(
                        title: TitleText(S.of(context).appearance),
                        subtitle: Text(S.of(context).customise_the_theme_and_primary_colors),
                        leading: new Icon(Icons.style),
                        onTap: (){
                          Navigator.push(context, FadeRoute(
                              builder: (context) => AppearanceSettingsPage(context)
                          ));
                        },
                      ),
                    ),

                    /*Material(
                      color: Theme.of(context).backgroundColor,
                      child: ListTile(
                        title: TitleText(S.of(context).launchpad),
                        subtitle: Text(S.of(context).customise_your_launchpad),
                        leading: new Icon(const IconData(0xe90F, fontFamily: 'apollotv-icons')),
                        onTap: (){
                          Navigator.push(context, FadeRoute(
                              builder: (context) => LaunchpadSettingsPage(context)
                          ));
                        },
                      ),
                    ),*/

                    Container(
                        margin: EdgeInsets.only(top: 35, bottom: 5, left: 15, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SubtitleText(
                              S.of(context).boost_your_experience,
                              padding: EdgeInsets.zero,
                            )
                          ],
                        )
                    ),

                    Material(
                      color: Theme.of(context).backgroundColor,
                      child: ListTile(
                        title: TitleText(S.of(context).extensions),
                        subtitle: Text(S.of(context).manage_third_party_integrations),
                        leading: new Icon(Icons.extension),
                        enabled: true,
                        onTap: (){
                          Navigator.push(context, FadeRoute(
                              builder: (context) => ExtensionsSettingsPage(context)
                          ));
                        },
                      ),
                    ),

                    Container(
                        margin: EdgeInsets.only(top: 35, bottom: 5, left: 15, right: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SubtitleText(
                              S.of(context).miscellaneous,
                              padding: EdgeInsets.zero,
                            )
                          ],
                        )
                    ),

                    Material(
                      color: Theme.of(context).backgroundColor,
                      child: ListTile(
                        title: TitleText(S.of(context).other_),
                        subtitle: Text(S.of(context).general_application_settings),
                        leading: new Icon(Icons.settings),
                        enabled: true,
                        onTap: (){
                          Navigator.push(context, FadeRoute(
                              builder: (context) => OtherSettingsPage(context)
                          ));
                        },
                      ),
                    ),

                    Material(
                      color: Theme.of(context).backgroundColor,
                      child: ListTile(
                        title: TitleText(S.of(context).advanced),
                        subtitle: Text(S.of(context).power_user_settings_for_rocket_scientists),
                        leading: new Icon(Icons.developer_mode),
                        enabled: true,
                        onTap: (){
                          Navigator.push(context, FadeRoute(
                              builder: (context) => AdvancedSettingsPage(context)
                          ));
                        },
                      ),
                    )

                    // It's okay to remove this, but we'd appreciate it if you
                    // keep it. <3
                    //__buildContributorCard()
                  ]
              )
          );
        })
    );
  }

  Widget __buildContributorCard(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Card(
        elevation: 10.0,
        color: Theme.of(context).cardColor,
        child: new Container(
            child: new Column(
              children: <Widget>[
                new Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Icon(Icons.accessibility),
                          new TitleText(
                            "  " + S.of(context).with_thanks,
                            fontSize: 24,
                          )
                        ]
                    )
                ),

                new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: new Text(
                        S.of(context).appname_was_made_possible_by_all_of_these_amazing_people(appName),
                        style: new TextStyle(
                            fontFamily: 'GlacialIndifference',
                            fontSize: 16
                        )
                    )
                ),

                new Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 40, top: 10),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: (
                        _contributors != null ?
                        _contributors.map((entry) {
                          if(entry.startsWith("##")){
                            // TITLE entry.
                            return new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  new Padding(
                                      padding: EdgeInsets.only(top: 20),
                                      child: TitleText(
                                          '${entry.replaceFirst("## ", "")}',
                                          textAlign: TextAlign.center,
                                          fontSize: 24
                                      )
                                  )
                                ]
                            );
                          }else{
                            // User entry
                            return new Row(
                                children: <Widget>[
                                  Text(
                                    entry,
                                    textAlign: TextAlign.left,
                                  )
                                ]
                            );
                          }
                        }).toList()
                            : <Widget>[
                          new CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation(
                                  Theme.of(context).primaryColor
                              )
                          )
                        ]
                    ),
                  ),
                )
              ],
            )
        ),
      ),
    );
  }

  String _getBuildType(){
    int buildType = int.tryParse(_packageInfo.buildNumber.split('').last);

    if(buildType != null) return SettingsView.buildTypes[buildType];
    return S.of(context).unknown;
  }

}
