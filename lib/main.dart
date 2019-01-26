// Import flutter libraries
import 'package:kamino/pages/all_media/all_genres.dart';
import 'package:kamino/view/settings/settings_prefs.dart' as settingsPref;
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/vendor/struct/ThemeConfiguration.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kamino/pages/favorites.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino/vendor/index.dart';

// Import custom libraries / utils
import 'animation/transition.dart';
// Import pages
import 'pages/launchpad.dart';
// Import views
import 'package:kamino/view/settings/settings.dart';

const appName = "ApolloTV";

Logger log;

void main(){
  // Setup logger
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((record) {
    print("[${record.loggerName}: ${record.level.name}] [${record.time}]: ${record.message}");
  });
  log = new Logger(appName);

  runApp(
    KaminoApp()
  );
}

class KaminoApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => KaminoAppState();

}

class KaminoAppState extends State<KaminoApp> {

  List<VendorConfiguration> _vendorConfigs;
  List<ThemeConfiguration> _themeConfigs;
  String _activeTheme;
  Color _primaryColorOverride;

  KaminoAppState(){
    // Load vendor and theme configs.
    _vendorConfigs = ApolloVendor.getVendorConfigs();
    _themeConfigs = ApolloVendor.getThemeConfigs();

    // Validate vendor and theme configs
    _themeConfigs.forEach((element){
      if(_themeConfigs.where((consumer) => element.getId() == consumer.getId()).length > 1)
        throw new Exception("Each theme must have a unique ID. Duplicate ID is: ${element.getId()}");
    });

    // Load active theme and primary color override.
    _activeTheme = _themeConfigs[0].getId();
    _primaryColorOverride = null;

    _loadActiveTheme();
  }

  Future<void> _loadActiveTheme() async {
    var theme = await settingsPref.getStringPref('activeTheme');
    var primaryColorOverride = await settingsPref.getStringPref('primaryColorOverride');

    setState(() {
      // If the restored theme setting pref is not null AND the theme exists,
      if(theme != null && _themeConfigs.where((consumer) => consumer.id == theme).length > 0)
        // then apply the theme if it is not already applied.
        if(_activeTheme != null) _activeTheme = theme;

      if(primaryColorOverride != null)
        if(_primaryColorOverride.toString() != primaryColorOverride)
          _primaryColorOverride = new Color(  int.parse(primaryColorOverride.split('(0x')[1].split(')')[0], radix: 16)  );

      // Update SystemUI
      SystemChrome.setSystemUIOverlayStyle(
          getActiveThemeMeta().getOverlayStyle().copyWith(
              statusBarColor: const Color(0x00000000),
              systemNavigationBarColor: getActiveThemeData().cardColor
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: appName,
        home: Launchpad(),
        theme: getActiveThemeData(),

        // Hide annoying debug banner
        debugShowCheckedModeBanner: false
    );
  }

  List<VendorConfiguration> getVendorConfigs(){
    return _vendorConfigs;
  }

  List<ThemeConfiguration> getThemeConfigs(){
    return _themeConfigs;
  }

  String getActiveTheme(){
    return _activeTheme;
  }

  ThemeConfigurationAdapter getActiveThemeMeta(){
    return ThemeConfigurationAdapter.fromConfig(
        _themeConfigs.singleWhere((consumer) => consumer.getId() == _activeTheme)
    );
  }

  ThemeData getActiveThemeData({ bool ignoreOverride: false }){
    if(_primaryColorOverride != null && !ignoreOverride)
      return _themeConfigs.singleWhere((consumer) => consumer.getId() == _activeTheme)
          .getThemeData(primaryColor: _primaryColorOverride);

    return _themeConfigs.singleWhere((consumer) => consumer.getId() == _activeTheme)
        .getThemeData();
  }

  void setActiveTheme(String activeTheme){
    setState((){
      _activeTheme = activeTheme;

      // MD2: Update SystemUI theme and status bar transparency
      SystemChrome.setSystemUIOverlayStyle(
          getActiveThemeMeta().getOverlayStyle().copyWith(
            statusBarColor: const Color(0x00000000),
            systemNavigationBarColor: getActiveThemeData().cardColor,
          )
      );

      // Update preferences
      settingsPref.savePref('activeTheme', activeTheme);
    });
  }

  Color getPrimaryColorOverride(){
    return _primaryColorOverride;
  }

  void setPrimaryColorOverride(Color color){
    setState(() {
      _primaryColorOverride = color;
      setActiveTheme(getActiveTheme());

      settingsPref.savePref('primaryColorOverride', color.toString());
    });
  }

}

class Launchpad extends StatefulWidget {

  @override
  LaunchpadState createState() => LaunchpadState();

}

class LaunchpadState extends State<Launchpad> with SingleTickerProviderStateMixin {

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  void initState() {
    ApolloVendor.getLaunchpadConfiguration().initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
          // backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Image.asset(
              appState.getActiveThemeData().brightness == Brightness.dark ?
                "assets/images/header_text.png" : "assets/images/header_text_dark.png",
              width: 125
            ),

            // MD2: make the color the same as the background.
            backgroundColor: Theme.of(context).cardColor,
            elevation: 5.0,
              actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.favorite),
                  tooltip: "Favorites",
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => FavoritesPage()
                    ));
                  },
              ),
            ],

            // Center title
            centerTitle: true
          ),
          drawer: __buildAppDrawer(),

          // Body content
          body: LaunchpadController()
      )
    );
  }

  _openAllGenres(BuildContext context, String mediaType) {

    if (mediaType == "tv") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AllGenres(contentType: mediaType)
          )
      );
    } else if (mediaType == "movie"){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AllGenres(contentType: mediaType)
          )
      );
    }
  }

  Widget __buildAppDrawer(){
    return Drawer(
      child: ListView(

          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                child: null,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/header.png'),
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.bottomCenter),
                    color: const Color(0xFF000000)
                )
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: Text("Blog"),
              onTap: () => _launchURL("https://medium.com/apolloblog"),
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.live_tv),
              title: Text('TV Shows'),
              onTap: () => _openAllGenres(context, "tv"),
            ),
            ListTile(
              leading: const Icon(Icons.local_movies),
              title: Text('Movies'),
              onTap: () => _openAllGenres(context, "movie"),
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.gavel),
              title: Text('Legal'),
              onTap: () => _launchURL("https://apollotv.xyz/legal/privacy"),
            ),
            ListTile(
              leading: const Icon(Icons.accessibility),
              title: Text('Donate'),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext _ctx){
                  return AlertDialog(
                    title: TitleText("Thanks for your interest!"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("We're grateful for your support but we don't have donations set up at the moment."),
                        Container(margin: EdgeInsets.only(top: 15)),
                        Text("If you're really interested in donating, I recommend joining our Discord server; where you'll find app development discussion and we'll keep you updated on our news.")
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
                }
              ),
            ),
            ListTile(
              enabled: true,
              leading: const Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();

                Navigator.push(context, SlideRightRoute(
                    builder: (context) => SettingsView()
                ));
              }
            )
          ],
        )
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}