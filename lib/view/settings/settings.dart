import 'package:kamino/animation/transition.dart';
import 'package:kamino/util/trakt.dart';
import 'package:kamino/view/settings/page_launchpad.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kamino/main.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/view/settings/page_appearance.dart';
import 'package:kamino/view/settings/page_other.dart';
import 'package:package_info/package_info.dart';

class SettingsView extends StatefulWidget {

  @override
  _SettingsViewState createState() => _SettingsViewState();

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
    _fetchContributors();

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
          title: TitleText("Settings"),

          backgroundColor: Theme.of(context).backgroundColor,

          // Center title
          centerTitle: true,
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Container(
            color: Theme.of(context).backgroundColor,
            child: new ListView(

                // It's recommended that you give at maximum three examples per setting category.

                children: <Widget>[

                  Padding(padding: EdgeInsets.symmetric(vertical: 5)),

                  Material(
                    color: Theme.of(context).backgroundColor,
                    child: ListTile(
                      title: TitleText("Launchpad"),
                      subtitle: Text("Modify your $appName launchpad."),
                      leading: new Icon(const IconData(0xe90B, fontFamily: 'apollotv-icons')),
                      onTap: (){
                        Navigator.push(context, SlideRightRoute(
                            builder: (context) => LaunchpadSettingsPage()
                        ));
                      },
                    ),
                  ),

                  Material(
                    color: Theme.of(context).backgroundColor,
                    child: ListTile(
                      title: TitleText("Appearance"),
                      subtitle: Text("Change theme, Choose color scheme, ..."),
                      leading: new Icon(Icons.palette),
                      enabled: true,
                      onTap: (){
                        Navigator.push(context, SlideRightRoute(
                            builder: (context) => AppearanceSettingsPage()
                        ));
                      },
                    ),
                  ),

                  Material(
                    color: Theme.of(context).backgroundColor,
                    child: ListTile(
                      title: TitleText("Other"),
                      subtitle: Text("Search preferences, Change language, Choose player, ..."),
                      leading: new Icon(Icons.settings),
                      enabled: true,
                      onTap: (){
                        Navigator.push(context, SlideRightRoute(
                            builder: (context) => OtherSettingsPage()
                        ));
                      },
                    ),
                  ),

                  Divider(),

                  // App Version
                  ListTile(
                      title: TitleText("$appName (${appState.getVendorConfigs()[0].getName()} ${_getBuildType()} Build)"),
                      subtitle: Text("v${_packageInfo.version}_build-${_packageInfo.buildNumber}"),
                      leading: new Image.asset("assets/images/logo.png", width: 36, height: 36)
                  ),

                  // It's okay to remove this, but we'd appreciate it if you
                  // keep it. <3
                  __buildContributorCard()
                ]
            )
          );
        }));
  }

  Widget __buildContributorCard(){
    return Card(
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
                          "  With thanks...",
                          fontSize: 24,
                        )
                      ]
                  )
              ),

              new Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: new Text(
                      "$appName was made possible by all of these amazing people:",
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
    );
  }

  String _getBuildType(){
    int buildType = int.tryParse(_packageInfo.buildNumber.split('').last);

    if(buildType != null) return SettingsView.buildTypes[buildType];
    return "Unknown";
  }

}
