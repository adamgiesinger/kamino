import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino/skyspace/tv_remote.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/vendor/themes/OfficialVendorThemes.dart';

class KaminoSkyspace extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => KaminoSkyspaceState();

}

class KaminoSkyspaceState extends State<StatefulWidget> {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "Skyspace",
        home: Skyspace(),
        theme: OfficialVendorTheme.dark.getThemeData(),

        // Hide annoying debug banner
        debugShowCheckedModeBanner: false
    );
  }

}

class Skyspace extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => SkyspaceState();

}

class SkyspaceState extends State<Skyspace> {

  int _currentPage;

  bool _initializedFocusNode = false;
  FocusNode _focusNode = new FocusNode();

  @override
  void initState() {

    _currentPage = 0;

    _focusNode.addListener((){
      print("Has focus: ${_focusNode.hasFocus}");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(!_initializedFocusNode){
      FocusScope.of(context).requestFocus(_focusNode);
      _initializedFocusNode = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141517),

      body: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (event){
          if(!(event.data is RawKeyEventDataAndroid)) return;
          if(!(event is RawKeyUpEvent)) return;

          var _event = event.data as RawKeyEventDataAndroid;

          switch(_event.keyCode){
            case TVRemote.UP_ARROW:
              print("^");
              break;

            case TVRemote.DOWN_ARROW:
              print("v");
              break;

            case TVRemote.LEFT_ARROW:
              print("<");
              break;

            case TVRemote.RIGHT_ARROW:
              print(">");
              break;

            case TVRemote.OK:
              print("[OK]");
              break;
          }
        },
        child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Material(
                color: const Color(0xFF1C2024),
                elevation: 4,

                child: Container(
                  width: 70,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[

                      Container(
                        margin: EdgeInsets.all(10),
                        child: Image.asset("assets/images/logo.png")
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Icon(
                          Icons.home,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Icon(Icons.local_movies, size: 24),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Icon(Icons.live_tv, size: 24),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Icon(Icons.favorite, size: 24),
                      ),

                      Expanded(
                          child: Container(
                            margin: EdgeInsets.all(20),
                            alignment: Alignment.bottomCenter,
                            child: Icon(Icons.settings, size: 24),
                          )
                      ),

                    ],
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  child: renderCurrentPage(),
                ),
              )
            ]
        ),
      )
    );
  }

  Widget renderCurrentPage(){
    switch(_currentPage) {
      case 0:
        return Container(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(const IconData(0xe90F, fontFamily: 'apollotv-icons'), size: 72),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: TitleText(
                      "Houston, Stand by...",
                      textColor: Colors.white,
                      fontSize: 20
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text("Apollo Skyspace is still under development. Please check back later."),
                )
              ],
            )
          ),
        );
        break;

      default:
        return Container();
    }
  }

}