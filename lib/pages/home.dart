import 'package:cplayer/cplayer.dart';
import 'package:flutter/material.dart';
import 'package:kamino/pages/search.dart';
import 'package:kamino/partials/apollowidgets/home_customise.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/pages/smart_search/smart_search.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Theme.of(context).backgroundColor,
      child: new ListView(children: [
        Container(margin: EdgeInsets.only(top: 5)),

        Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: new Material(
            elevation: 5,
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: (){
                /*
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => SmartSearch()
                ));
                */
                showSearch(context: context, delegate: SmartSearch());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 15, left: 20),
                    child: new Text(
                      'Search TV shows and movies...',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'GlacialIndifference',
                          color: Colors.grey
                      ),
                    ),
                  ),

                  new Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: new Icon(
                        Icons.search,
                        color: Colors.grey,
                      )
                  )
                ],
              ),
            ),
          ),
        ),

        HomeCustomiseWidget(),

        new Container(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: new Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
            ),
            elevation: 3.0,
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.developer_mode),
                  title: TitleText('Debug Card'),
                  subtitle: const Text('Developer options.'),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, bottom: 15),
                  child: new RaisedButton(
                    onPressed: (){
                      print("Launching Player");
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CPlayer(
                            url: "http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_60fps_normal.mp4",
                            title: "Big Buck Bunny",
                            mimeType: "video/mp4",
                          ))
                      );
                    },
                    child: Text("Debug Player"),
                  ),
                )
              ],
            )
          )
        )
      ])
    );
  }
}
