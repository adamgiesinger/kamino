import 'package:cplayer/cplayer.dart';
import 'package:flutter/material.dart';
import 'package:kamino/ui/ui_elements.dart';

class DeveloperWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: new Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
                    onPressed: () {
                      print("Launching Player");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CPlayer(
                                url:
                                "http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_60fps_normal.mp4",
                                title: "Big Buck Bunny",
                                mimeType: "video/mp4",
                              )));
                    },
                    child: Text("Debug Player"),
                  ),
                )
              ],
            )));
  }



}