import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino/models/tvshow.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/view/content/episodePicker.dart';

import 'package:kamino/api/tmdb.dart' as tmdb;

class TVShowLayout{

  static Widget generate(BuildContext context, TVShowContentModel _data){
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
            children: <Widget>[

              /* Seasons Cards */
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                      title: TitleText(
                          'Seasons (${_data.seasons.length})',
                          fontSize: 22.0,
                          textColor: Theme.of(context).primaryColor
                      )
                  ),

                  _generateSeasonsCards(context, _data)
                ],
              )
              /* ./Seasons Cards */


            ]
        )
    );
  }

  static Widget _generateSeasonsCards(BuildContext context, TVShowContentModel _data){
    if(_data.seasons.length > 0){
      return new Column(
        children: _data.seasons.map((season) {
          var seasonIndex = _data.seasons.indexOf(season);

          // Format 'air date'.
          var airDate = "Ongoing";

          if(season["air_date"] != null){
            airDate = new DateFormat.yMMMMd("en_US").format(
                DateTime.parse(season["air_date"])
            );
          }

          // Determine season image
          var image = null;
          if(season["poster_path"] != null){
            image = "${tmdb.image_cdn}" + season["poster_path"];
          }

          // Create leading widget
          Widget leadingWidget = new Icon(Icons.live_tv);
          if(image != null){
            leadingWidget = new Image(
              image: (
                  NetworkImage(image)
              ),
              height: 92,
              width: 46,
            );
          }

          // Return Card & GestureDetector
          return new GestureDetector(
              onTap: (){
                _openEpisodesView(context, _data, seasonIndex);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                elevation: 2,
                color: Theme.of(context).cardColor,
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: leadingWidget,
                      title: TitleText(season["name"]),
                      subtitle: Text(
                          "${season["episode_count"]} episode${season["episode_count"] != 1 ? "s" : "" } \u2022 $airDate"
                      ),
                    )
                  ]
                )
              )
          );
        }).toList()
      );
    }

    return Container();
  }

  static void _openEpisodesView(
    BuildContext context,
    TVShowContentModel _data,
    int index
  ){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EpisodePicker(
            contentId: _data.id,
            showContentModel: _data,
            seasonIndex: _data.seasons[index]["season_number"]
        ))
    );
  }

}