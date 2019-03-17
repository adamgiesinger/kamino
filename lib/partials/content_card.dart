import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parallax/flutter_parallax.dart';
import 'package:intl/intl.dart';
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/interface/content/overview.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/models/movie.dart';

class ContentCard extends StatelessWidget {

  ContentModel model;
  double width;
  double height;

  ContentCard(this.model, {this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(8),

      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
        var height = this.height != null ? this.height : constraints.heightConstraints().maxHeight;
        var width = this.width != null ? this.width : constraints.widthConstraints().maxWidth;

        return Stack(
          fit: StackFit.expand,

          children: <Widget>[
            Parallax.inside(
                direction: AxisDirection.right,
                mainAxisExtent: height,
                child: CachedNetworkImage(
                  imageUrl: TMDB.IMAGE_CDN + model.backdropPath,
                  fit: BoxFit.cover,
                  placeholder: Container(color: Colors.black, width: width, height: height),
                  height: height,
                  width: width + 100,
                  errorWidget: new Icon(Icons.error, size: 30.0)
                )
              // height: 220.0,
              // fit: BoxFit.cover,
            ),

            Container(color: const Color(0x66000000)),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AutoSizeText(model.title, style: TextStyle(fontSize: 25.0, color: Colors.white), maxFontSize: 25.0, maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)
                ),
                Text(DateFormat.y("en_US").format(DateTime.parse(model.releaseDate)), style: TextStyle(fontSize: 16, color: Colors.white))
              ],
            ),

            Positioned(
              right: 20,
              bottom: 20,
              child: new Icon(
                (model is MovieContentModel) ? Icons.local_movies : Icons.live_tv,
                color: Colors.white,
              ),
            ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ContentOverview(
                        contentId: model.id,
                        contentType: (model is MovieContentModel) ? ContentType.MOVIE : ContentType.TV_SHOW,
                      )
                  ));
                },
              ),
            )
          ],
        );
      }),
    );
  }

}