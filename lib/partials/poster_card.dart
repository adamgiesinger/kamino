import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/ui/uielements.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PosterCard extends StatefulWidget {

  final String background;
  final String name;
  final double elevation;
  final List<String> genre;
  final String mediaType;
  final int ratings;
  final String overview;
  final bool isFav;

  PosterCard({
    @required this.background,
    @required this.name,
    @required this.genre,
    @required this.mediaType,
    @required this.ratings,
    @required this.overview,
    @required this.isFav,
    @required this.elevation
  });

  @override
  _PosterCardState createState() => _PosterCardState();

}

class _PosterCardState extends State<PosterCard> {

  Color _favouriteIndicator() {

    if (widget.isFav == true) {
      return Colors.yellow;
    }

    return Theme.of(context).accentTextTheme.body1.color;
  }

  String _genre(){
    String genreOverview = "";

    if (widget.genre.length == 1){
      return widget.genre[0];

    } else {

      widget.genre.forEach((String element){
        if (widget.genre.indexOf(element) == 0){
          genreOverview = element;
        }
        genreOverview = genreOverview + ", "+element;

      });
    }

    return genreOverview;
  }

  @override
  Widget build(BuildContext context) {

    Widget imageWidget = Container();

    double _imageHeight = 170.0;
    double _imageWidth = 105.0;
    double c_width = MediaQuery.of(context).size.width*0.8;

    if(widget.background != null) {
      /*
      imageWidget = new FadeInImage.assetNetwork(
        placeholder: "assets/images/no_image_detail.jpg",
        image: "${tmdb.image_cdn}/${widget.background}",
        fit: BoxFit.cover,
        height: _imageHeight,
        width: _imageWidth,
      );
      */

      imageWidget = CachedNetworkImage(
        imageUrl: tmdb.image_cdn + widget.background,
        fit: BoxFit.cover,
        placeholder: new Image(
          image: AssetImage("assets/images/no_image_detail.jpg"),
          fit: BoxFit.cover,
          height: _imageHeight,
          width: _imageWidth,
        ),
        height: _imageHeight,
        width: _imageWidth,
        errorWidget: new Icon(Icons.error, size: 20.0, color: Colors.red,),
      );

    }else{
      imageWidget = new Image(
          image: AssetImage("assets/images/no_image_detail.jpg"),
          fit: BoxFit.cover,
          height: _imageHeight,
          width: _imageWidth,
      );
    }

    const _containerWidth = 221.0;

    return Container(
      height: 170.0,
      child: Card(
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0),
              ),
              child: imageWidget,
            ),

            Padding(
              padding: const EdgeInsets.only(left: 11.0, right: 9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[

                  //Title of the poster
                  Container(
                    width: _containerWidth,
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontFamily: "GlacialIndifference",
                        color: _favouriteIndicator(),
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  //The list of genres for the content being displayed
                  Container(
                    width: _containerWidth,
                    padding: EdgeInsets.only(top: 6.0),
                    child: _genre() != null ? Text(
                      _genre(),
                      style: TextStyle(
                        //fontFamily: "GlacialIndifference",
                        color: _favouriteIndicator(),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ) : Container(),
                  ),

                  Container(
                    width: _containerWidth,
                    padding: EdgeInsets.only(top: 4.0),
                    child: StarRating(
                      rating: widget.ratings / 2, // Ratings are out of 10 from our source.
                      color: Theme.of(context).primaryColor,
                      borderColor: Theme.of(context).primaryColor,
                      size: 19.0,
                      starCount: 5,
                    ),
                  ),

                  //Over summary
                  widget.overview != null ? Container(
                    width: _containerWidth,
                    padding: EdgeInsets.only(top: 4.0, bottom: 8.0),
                    child: Text(
                      widget.overview,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        //fontFamily: "GlacialIndifference",
                        fontSize: 15.0,
                        color: _favouriteIndicator(),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ) : Container(),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}
