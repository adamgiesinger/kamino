import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino/res/BottomGradient.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;

import 'package:kamino/api/tmdb.dart' as tmdb;

class Poster extends StatefulWidget {

  final String background;
  final String name;
  final String releaseDate;
  final String mediaType;
  final bool isFav;

  Poster({
    @required this.background,
    @required this.name,
    @required this.releaseDate,
    @required this.mediaType,
    @required this.isFav
  });

  @override
  State<StatefulWidget> createState() => PosterState();

}

class PosterState extends State<Poster> {

  Color _favouriteIndicator() {

    if (widget.isFav == true) {
      return Colors.yellow;
    }

    return Theme.of(context).accentTextTheme.body1.color;
  }

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

    Widget imageWidget = Container();
    if(widget.background != null) {
      imageWidget = new FadeInImage.assetNetwork(
        placeholder: "assets/images/no_image_detail.jpg",
        image: "${tmdb.image_cdn}/${widget.background}",
        fit: BoxFit.cover,
        height: 752,
        width: 500,
      );
    }else{
      imageWidget = new Image(
        image: AssetImage("assets/images/no_image_detail.jpg"),
        fit: BoxFit.cover,
        height: 752,
        width: 500
      );
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
                child: imageWidget,
              )
          ),

          Padding(
              padding: EdgeInsets.all(3.5),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: BottomGradient(finalStop: 0.025)
              )
          ),

          Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Padding(
                      padding: EdgeInsets.only(bottom: 2, left: 10, right: 10),
                      child: TitleText(
                        widget.name,
                        fontSize: 16,
                        textColor: _favouriteIndicator(),
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
                                  fontSize: 12,
                                color: _favouriteIndicator()
                              )
                          ),

                          Icon(
                              widget.mediaType == 'tv' ? Icons.tv : Icons.local_movies,
                              size: 16,
                            color: _favouriteIndicator(),
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