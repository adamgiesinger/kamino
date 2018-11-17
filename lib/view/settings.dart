import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kamino/animation/transition.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/view/easteregg.dart';
import 'package:package_info/package_info.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
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
    super.initState();
    _fetchPackageInfo();
    _fetchContributors();
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
    return Scaffold(
        appBar: AppBar(
          title: TitleText("Settings"),
          backgroundColor: const Color(0xFF000000),
          // Remove box-shadow
          elevation: 0.00,

          // Center title
          centerTitle: true,
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Container(
            color: backgroundColor,
            child: new ListView(

                children: <Widget>[
                  // App Version
                  ListTile(
                      title: TitleText("$appName Version"),
                      subtitle: Text(
                          "v${_packageInfo.version}_build-${_packageInfo.buildNumber}"),
                      onTap: () {
                        versionTapCount += 1;
                        if (versionTapCount >= 10) {
                          Navigator.push(context,
                              SlideLeftRoute(builder: (context) => EasterEggView()));

                          versionTapCount = 0;
                        }
                      }
                  ),

                  __buildContributorCard()
                ]
            )
          );
        }));
  }

  Widget __buildContributorCard(){
    return Card(
      elevation: 10.0,
      color: const Color(0xFF000000),
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
                      "ApolloTV was made possible by all of these amazing people...",
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
                                primaryColor
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

}
