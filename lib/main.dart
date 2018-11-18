// Import flutter libraries
import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:kamino/pages/_page.dart';
import 'package:kamino/ui/uielements.dart';

// Import custom libraries / utils
import 'animation/transition.dart';
// Import pages
import 'pages/home.dart';
import 'pages/search.dart';
import 'pages/favorites.dart';
// Import views
import 'view/settings.dart';

var themeData = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  accentColor: secondaryColor,
  splashColor: backgroundColor,
  highlightColor: highlightColor,
  backgroundColor: backgroundColor,
  cursorColor: primaryColor,
  textSelectionHandleColor: primaryColor
);

const primaryColor = const Color(0xFF8147FF);
const secondaryColor = const Color(0xFF303A47);
const backgroundColor = const Color(0xFF26282C);
const highlightColor = const Color(0x968147FF);
const appName = "ApolloTV";

void main() {
  // MD2: Remove status bar translucency.
  changeStatusColor(Color color) async {
    try {
      await FlutterStatusbarcolor.setStatusBarColor(color);
    } on PlatformException catch (e) {
      print(e);
    }
  }
  changeStatusColor(const Color(0x00000000));

  runApp(
    new MaterialApp(
        title: appName,
        home: KaminoApp(),
        theme: themeData,

        // Hide annoying debug banner
        debugShowCheckedModeBanner: false),
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
        icon: Icon(
            const IconData(0xe900, fontFamily: 'apollotv-icons')
        )
    ): HomePage(),

    // Search
    Tab(
        icon: Icon(Icons.search)
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

//    _tabController.addListener((){
//      setState((){
//        if(_tabController.indexIsChanging){ return; }
//        if(_pages.values.toList()[_tabController.index] != null) {
//          _currentTitle = _pages.values.toList()[_tabController.index].getTitle();
//        }
//      });
//    });
//
//    _currentTitle = _pages.values.toList()[_tabController.index].getTitle();
  }

  @override
  void destroy(){
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: TitleText(appName),
          // MD2: make the color the same as the background.
          backgroundColor: backgroundColor,
          // Remove box-shadow
          elevation: 0.00,

          // Center title
          centerTitle: true,
        ),
        drawer: __buildAppDrawer(),
        bottomNavigationBar: TabBar(
          controller: _tabController,
          tabs: _pages.keys.toList(),

          indicatorColor: primaryColor,
          indicatorSize: TabBarIndicatorSize.tab,

          labelColor: primaryColor,
          unselectedLabelColor: Colors.white30
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
                        image: AssetImage('images/header.png'),
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
                leading: const Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  Navigator.of(context).pop();

                  Navigator.push(context,
                      SlideLeftRoute(builder: (context) => SettingsView()));
                }
            )
          ],
        ),
      )
    );
  }

}