// Import flutter libraries
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/interface/launchpad2/Launchpad2.dart';
import 'package:kamino/interface/settings/utils/ota.dart' as OTA;
import 'package:kamino/interface/smart_search/smart_search.dart';
import 'package:kamino/skyspace/skyspace.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/util/settings.dart';
import 'package:kamino/vendor/struct/ThemeConfiguration.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';
import 'package:logging/logging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino/vendor/index.dart';

// Import custom libraries / utils
// Import pages
// Import views
import 'package:kamino/interface/settings/settings.dart';

const appName = "ApolloTV";
Logger log;

const platform = const MethodChannel('xyz.apollotv.kamino/init');

class PlatformType {
  static const GENERAL = 0;
  static const TV = 1;
}

void main(){
  // Setup logger
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((record) {
    print("[${record.loggerName}: ${record.level.name}] [${record.time}]: ${record.message}");
  });
  log = new Logger(appName);

  // Get device type
  () async {
    return (await platform.invokeMethod('getDeviceType')) as int;
  }().then((platformType){
    if(platformType == PlatformType.TV) return runApp(KaminoSkyspace());
    runApp(KaminoApp());
  });
}

class KaminoApp extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => KaminoAppState();

}

class KaminoAppState extends State<KaminoApp> {

  Locale _currentLocale;

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
    _loadLocale();
  }

  Future<void> setLocale(Locale locale) async {
    await (Settings.locale = [locale.languageCode, locale.countryCode]);
    await _loadLocale();
  }

  Future<void> _loadLocale() async {
    if(!SettingsManager.hasKey("locale")) return;
    var localePref = await Settings.locale;

    setState(() {
      _currentLocale = Locale(localePref[0], localePref[1]);
    });
  }

  Future<void> _loadActiveTheme() async {
    var theme = await (Settings.activeTheme);
    var primaryColorOverride = await (Settings.primaryColorOverride);

    setState(() {
      // If the restored theme setting pref is not null AND the theme exists,
      if(theme != null && _themeConfigs.where((consumer) => consumer.id == theme).length > 0)
        // then apply the theme if it is not already applied.
        if(_activeTheme != null) _activeTheme = theme;

      if(primaryColorOverride != null)
        if(_primaryColorOverride.toString() != primaryColorOverride)
          _primaryColorOverride = new Color(int.parse(primaryColorOverride.split('(0x')[1].split(')')[0], radix: 16));

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
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      locale: _currentLocale != null ? _currentLocale : Locale('en'),

      title: appName,
      home: KaminoAppHome(),
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
      Settings.activeTheme = activeTheme;
    });
  }

  Color getPrimaryColorOverride(){
    return _primaryColorOverride;
  }

  void setPrimaryColorOverride(Color color){
    setState(() {
      _primaryColorOverride = color;
      setActiveTheme(getActiveTheme());

      Settings.primaryColorOverride = color.toString();
    });
  }

}

class KaminoAppHome extends StatefulWidget {

  @override
  KaminoAppHomeState createState() => KaminoAppHomeState();

}

class KaminoAppHomeState extends State<KaminoAppHome> with SingleTickerProviderStateMixin {

  Future<bool> _onWillPop() async {
    // Allow app close on back
    return true;
  }

  @override
  void initState() {
    OTA.updateApp(context, true);
    ApolloVendor.getLaunchpadConfiguration().initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          // backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Row(
              children: <Widget>[
                Image.asset(
                    appState.getActiveThemeData().brightness == Brightness.dark ?
                    "assets/images/header_text.png" : "assets/images/header_text_dark.png",
                    height: kToolbarHeight - 38
                )
              ],
            ),

            //backgroundColor: Theme.of(context).backgroundColor,
            //elevation: 0,

            backgroundColor: Theme.of(context).cardColor,
            elevation: 5.0,

            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.search),
                  tooltip: "Search",
                  onPressed: (){
                    showSearch(context: context, delegate: SmartSearch());
                  },
              ),

              PopupMenuButton<String>(
                tooltip: "Options",
                icon: Icon(Icons.more_vert),
                onSelected: (String index){
                  switch(index){
                    case 'discord': return Interface.launchURL("https://discord.gg/euyQRWs");
                    case 'blog': return Interface.launchURL("https://medium.com/apolloblog");
                    case 'privacy': return Interface.launchURL("https://apollotv.xyz/legal/privacy");
                    case 'donate': return Interface.launchURL("https://apollotv.xyz/donate");
                    case 'settings': return Navigator.push(context, MaterialPageRoute(
                        builder: (context) => SettingsView()
                    ));

                    default: Interface.showSnackbar("Invalid menu option. Option '$index' was not defined.");
                  }
                },
                itemBuilder: (BuildContext context){
                  return [
                    PopupMenuItem<String>(
                      value: 'discord',
                      child: Container(child: Text("Discord"), padding: EdgeInsets.only(right: 50)),
                    ),

                    PopupMenuItem<String>(
                      value: 'blog',
                      child: Container(child: Text("Blog"), padding: EdgeInsets.only(right: 50))
                    ),

                    PopupMenuItem<String>(
                      value: 'privacy',
                      child: Container(child: Text("Privacy"), padding: EdgeInsets.only(right: 50))
                    ),

                    PopupMenuItem<String>(
                      value: 'donate',
                      child: Container(child: Text("Donate"), padding: EdgeInsets.only(right: 50))
                    ),

                    PopupMenuItem<String>(
                      value: 'settings',
                      child: Container(child: Text("Settings"), padding: EdgeInsets.only(right: 50))
                    )
                  ];
                }
              )
            ],

            // Center title
            centerTitle: false
          ),
          //drawer: __buildAppDrawer(),

          // Body content
          body: Launchpad2(),
      )
    );
  }

}