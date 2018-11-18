import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino/res/BottomGradient.dart';
import 'package:kamino/ui/uielements.dart';

import 'package:kamino/vendor/config/official.dart' as api;

class Poster extends StatefulWidget {

  final String background;
  final String name;
  final String releaseDate;
  final String mediaType;

  Poster({
    @required this.background,
    @required this.name,
    @required this.releaseDate,
    @required this.mediaType
  });

  @override
  State<StatefulWidget> createState() => PosterState();

}

class PosterState extends State<Poster> {

  @override
  Widget build(BuildContext context) {
    var releaseYear = "";
    if(widget.releaseDate != null){
      try {
        releaseYear = new DateFormat.y("en_US").format(
            DateTime.parse(widget.releaseDate));
      }catch(ex){
        releaseYear = "Unknown";
      }
    }

    return Container(
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.bottomCenter,

        children: <Widget>[
          Card(
              elevation: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: new FadeInImage.assetNetwork(
                  placeholder: "assets/images/no_image_detail.jpg",
                  image: "${api.tvdb_image_cdn}/${widget.background}",
                  fit: BoxFit.cover,
                  height: 752,
                  width: 500,
                ),
              )
          ),

          Padding(
              padding: EdgeInsets.all(3.5),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: BottomGradient()
              )
          ),

          Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Padding(
                      padding: EdgeInsets.only(bottom: 2, left: 10, right: 10),
                      child: TitleText(
                        widget.name,
                        fontSize: 16,
                      )
                  ),

                  Padding(
                      padding: EdgeInsets.only(
                          top: 0,
                          bottom: 10,
                          left: 10,
                          right: 10
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                              releaseYear,
                              style: TextStyle(
                                  fontSize: 12
                              )
                          ),

                          Icon(
                              widget.mediaType == 'tv' ? Icons.tv : Icons.local_movies,
                              size: 16
                          )
                        ],
                      )
                  )
                ],
              )
          )
        ],
      ),
    );
  }

}