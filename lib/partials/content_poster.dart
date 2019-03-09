import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino/res/BottomGradient.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:kamino/api/tmdb.dart';

class ContentPoster extends StatefulWidget {

  final String background;
  final String name;
  final String releaseDate;
  final String mediaType;
  final bool isFav;
  final double height, width;
  final BoxFit imageFit;
  final bool hideIcon;

  ContentPoster({
    @required this.background,
    @required this.name,
    @required this.releaseDate,
    @required this.mediaType,
    @required this.isFav,
    this.width = 500,
    this.height = 750.0,
    this.imageFit = BoxFit.cover,
    this.hideIcon = false
  });

  @override
  State<StatefulWidget> createState() => ContentPosterState();

}

class ContentPosterState extends State<ContentPoster> {

  Color _favoriteIndicator() {

    if (widget.isFav == true) {
      return Colors.yellow;
    }

    return Colors.white;
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
      imageWidget = new CachedNetworkImage(
        errorWidget: new Icon(Icons.error),

        imageUrl: "${TMDB.IMAGE_CDN_POSTER}/${widget.background}",
        fit: widget.imageFit,
        placeholder: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor
              ),
            ),
        ),
        height: widget.height,
        width: widget.width,
      );
    }else{
      imageWidget = new Image(
        image: AssetImage("assets/images/no_image_detail.jpg"),
        fit: widget.imageFit,
        height: widget.height,
        width: widget.width,
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
                        textColor: _favoriteIndicator(),
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
                                color: _favoriteIndicator()
                              )
                          ),

                          widget.hideIcon == false ? Icon(
                              widget.mediaType == 'tv' ? Icons.tv : Icons.local_movies,
                              size: 16,
                            color: _favoriteIndicator(),
                          ) : Container()
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