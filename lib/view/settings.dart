import 'package:kamino/vendor/index.dart';

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kamino/main.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:package_info/package_info.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  SharedPreferences _preferences;

  bool _useClientSideResolver = false;

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
    _readSharedPrefs();
    _fetchPackageInfo();
    _fetchContributors();
  }

  Future<Null> _fetchPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void _readSharedPrefs() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      _useClientSideResolver = _preferences.getBool('useClientSideResolver') ?? false;
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

          backgroundColor: Theme.of(context).backgroundColor,

          // Center title
          centerTitle: true,
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Container(
            color: Theme.of(context).backgroundColor,
            child: new ListView(

                // It's recommended that you give at maximum three examples per setting category.

                children: __buildPreferences()
            )
          );
        }));
  }

  List<Widget> __buildPreferences() {
    var vendorConfig = vendorConfigs[0];

    var widgets = <Widget>[
      Padding(padding: EdgeInsets.symmetric(vertical: 5)),

      ListTile(
        title: TitleText("Launchpad"),
        subtitle: Text("Modify your $appName launchpad."),
        leading: new Icon(const IconData(0xe90B, fontFamily: 'apollotv-icons')),
      ),

      ListTile(
          title: TitleText("Appearance"),
          subtitle: Text("Change theme, [...]"),
          leading: new Icon(Icons.palette)
      ),

      ListTile(
        title: TitleText("Other"),
        subtitle: Text("Change language, choose sources, [...]"),
        leading: new Icon(Icons.settings),
      ),
    ];

    if (vendorConfig.supportsClientSideResolver) {
      widgets.add(
          SwitchListTile(
            title: TitleText("Use client-side resolver"),
            subtitle: Text(
                "Resolve all links on your device, bypassing the remote servers."),
            value: _useClientSideResolver,
            onChanged: (bool status) {
              _preferences.setBool('useClientSideResolver', status);
              setState(() {
                _useClientSideResolver = status;
              });
            },
          )
      );
    }

    widgets.addAll(
        <Widget>[
          Divider(),

          // App Version
          ListTile(
              title: TitleText("$appName (${vendorConfig.getName()} Build)"),
              subtitle:
              Text(
                  "v${_packageInfo.version}_build-${_packageInfo.buildNumber}"),
              leading: new Image.asset(
                  "assets/images/logo.png", width: 36, height: 36)
          ),

          // It's okay to remove this, but we'd appreciate it if you
          // keep it. <3
          __buildContributorCard()
        ]);
    return widgets;
  }

  Widget __buildContributorCard(){
    return Card(
      elevation: 10.0,
      color: const Color(0xFF2F3136),
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

}
