// Import flutter libraries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:kamino/ui/uielements.dart';

// Import custom libraries / utils
import 'animation/transition.dart';
// Import pages
import 'pages/home.dart';
// Import views
import 'view/search.dart';
import 'view/settings.dart';
import 'package:kamino/view/home/tv_shows/tv_home.dart';

const primaryColor = const Color(0xFF8147FF);
const secondaryColor = const Color(0xFF241644);
const backgroundColor = const Color(0xFF27282C);
const highlightColor = const Color(0x968147FF);
const appName = "ApolloTV";

var themeData = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    accentColor: secondaryColor,
    splashColor: backgroundColor,
    highlightColor: highlightColor,
    backgroundColor: backgroundColor
);

void main() {
  // MD2: Remove status bar translucency.

  /*

    [ATV: Status Bar Theming Guidelines]
    -> Primary Brand Color:   Content Page
    -> Black:                 Important Content / Changing Settings

   */

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

class HomeAppState extends State<KaminoApp> with AutomaticKeepAliveClientMixin<KaminoApp>{
  List<Widget> _tabScreens = [new Homepage(), new TVHome()];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: TitleText(appName),
          // MD2: make the color the same as the background.
          backgroundColor: backgroundColor,
          // Remove box-shadow
          elevation: 5.0,

          // Center title
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(
                    const IconData(
                        0xe90a, fontFamily: 'apollotv-icons')),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => new SearchView())
                  );
                }
            ),
          ],
        ),
        drawer: Drawer(
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
                    color: const Color(0xFF000000))),
            ListTile(
                leading: const Icon(Icons.library_books), title: Text("News"),
            ),
            Divider(),
            ListTile(
                leading: const Icon(Icons.gavel), title: Text('Disclaimer')),
            ListTile(
                leading: const Icon(Icons.favorite), title: Text('Donate')),
            ListTile(
                leading: const Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  Navigator.of(context).pop();

                  Navigator.push(context,
                      SlideLeftRoute(builder: (context) => SettingsView()));
                })
          ],
        )),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
            onTap: onTabTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(const IconData(0xe900, fontFamily: 'apollotv-icons')),
                backgroundColor: backgroundColor,
                title: Text("Discover"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.movie),
                backgroundColor: backgroundColor,
                title: Text("Movies"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.live_tv),
                backgroundColor: backgroundColor,
                title: Text("TV Shows"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                backgroundColor: backgroundColor,
                title: Text("Favourites"),
              ),
            ],
        ),

        // Body content
        body: _tabScreens[_currentIndex],
    );
  }

  void onTabTapped(int index) {
    print("The index is:    $index");
    setState(() {
      _currentIndex = index;
    });
  }

  // TODO: implement wantKeepAlive
  @override
  bool get wantKeepAlive => true;
}
