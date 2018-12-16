// Import flutter libraries
import 'dart:collection';
import 'package:logging/logging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino/pages/_page.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/vendor/index.dart';

// Import custom libraries / utils
import 'animation/transition.dart';
// Import pages
import 'pages/home.dart';
import 'pages/search.dart';
import 'pages/favorites.dart';
// Import views
import 'view/settings.dart';

const appName = "ApolloTV";

Logger log;

var vendorConfigs = ApolloVendor.getVendorConfigs();
var themeConfigs = ApolloVendor.getThemeConfigs();
var activeTheme = 0;

void main(){
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((record) {
    print("[${record.loggerName}: ${record.level.name}] [${record.time}]: ${record.message}");
  });
  log = new Logger(appName);

  // MD2: Force SystemUI dark theme and status bar transparency
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: const Color(0x00000000),
    systemNavigationBarColor: const Color(0xFF000000)
  ));

  runApp(
    new MaterialApp(
      title: appName,
      home: KaminoApp(),
      theme: themeConfigs[activeTheme].getThemeData(),

      // Hide annoying debug banner
      debugShowCheckedModeBanner: false
    ),
  );
}

class KaminoApp extends StatefulWidget {
  @override
  HomeAppState createState() => new HomeAppState();
}

class HomeAppState extends State<KaminoApp> with SingleTickerProviderStateMixin {

//  String _currentTitle = appName;
  TabController _tabController;

  LinkedHashMap<Tab, Page> _pages = {
    // Favorites
    Tab(
      icon: Icon(Icons.favorite)
    ): FavoritesPage(),

    // Homepage
    Tab(
      icon: Image(
          //const IconData(0xe90B, fontFamily: 'apollotv-icons')
        image: AssetImage("assets/images/logo_foreground.png"),
        height: 32,
      )
    ): HomePage(),

    // Search
    Tab(
      icon: Icon(Icons.search),
    ): SearchPage()
  } as LinkedHashMap<Tab, Page>;

  @override
  void initState(){
    super.initState();

    _tabController = new TabController(
        length: _pages.length,
        vsync: this,
        initialIndex: 1
    );
  }

  @override
  void destroy(){
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        // backgroundColor: backgroundColor,
        appBar: AppBar(
          title: TitleText(appName),
          // MD2: make the color the same as the background.
          backgroundColor: Theme.of(context).cardColor,
          elevation: 5.0,

          // Center title
          centerTitle: true,
        ),
        drawer: __buildAppDrawer(),
        bottomNavigationBar: Material(
          color: Theme.of(context).cardColor,
          child: TabBar(
              controller: _tabController,
              tabs: _pages.keys.toList(),

              indicatorColor: Theme.of(context).primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,

              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.white30
          ),
          elevation: 5.0
        ),

        // Body content
        body: TabBarView(
          controller: _tabController,
          children: _pages.values.toList()
        )
    );
  }

  Widget __buildAppDrawer(){
    return Drawer(
      child: Container(
        color: const Color(0xFF32353A),
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
                title: Text("News")
            ),
            Divider(),
            ListTile(
                leading: const Icon(Icons.gavel),
                title: Text('Disclaimer')
            ),
            ListTile(
                leading: const Icon(Icons.favorite),
                title: Text('Donate')
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
        ),
      )
    );
  }

}