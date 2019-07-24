import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/skyspace/tv_remote.dart';
import 'package:kamino/ui/elements.dart';

class KaminoSkyspace extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => KaminoSkyspaceState();

}

class KaminoSkyspaceState extends State<KaminoSkyspace> {

  int _currentPage;

  @override
  void initState() {
    _currentPage = 0;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SkyspaceRemoteWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFF141517),

        body: Row(
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
        )
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
                      S.of(context).houston_stand_by,
                      textColor: Colors.white,
                      fontSize: 20
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(S.of(context).apollo_skyspace_is_still_under_development + "\n" + S.of(context).we_will_announce_it_on_our_social_pages_when_its),
                ),
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