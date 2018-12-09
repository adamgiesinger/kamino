import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_parallax/flutter_parallax.dart';

import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/main.dart';
import 'package:kamino/models/tvshow.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/interface.dart';

class EpisodePicker extends StatefulWidget {
  final int contentId;
  final int seasonIndex;
  final TVShowContentModel showContentModel;

  EpisodePicker({
    Key key,
    @required this.contentId,
    @required this.seasonIndex,
    @required this.showContentModel
  }) : super(key: key);

  @override
  _EpisodePickerState createState() => new _EpisodePickerState();
}

class _EpisodePickerState extends State<EpisodePicker> {

  ScrollController _controller;
  SeasonModel _season;

  @override
  void initState() {
    // When the widget is initialized, download the overview data.
    loadDataAsync().then((data) {
      // When complete, update the state which will allow us to
      // draw the UI.
      setState(() {
        _season = data;
      });
    });

    super.initState();
    _controller = new ScrollController();
  }

  // Load the data from the source.
  Future<SeasonModel> loadDataAsync() async {
    String url = "${tmdb.root_url}/tv/${widget.contentId}/season/"
        "${widget.seasonIndex}${tmdb.default_arguments}";

    http.Response response  = await http.get(url);

    var _json = jsonDecode(response.body);
    return new SeasonModel(_json["season_number"],
        _json["id"], _json["name"], _json["episodes"], _json["air_date"]);
  }

  /* THE FOLLOWING CODE IS JUST LAYOUT CODE. */

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: TitleText(_season != null ? "${widget.showContentModel.title} - ${_season.name}" : "Loading..."),
        centerTitle: true,
      ),
      body: _season == null ?

        // Shown whilst loading...
        Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor
              ),
            )
        ) :

        // Shown once loading is complete.
        ListView.builder(
          controller: _controller,
          itemCount: _season.episodes.length,
          itemBuilder: (BuildContext listContext, int index){
            var episode = _season.episodes[index];
            var airDate = "Unknown";

            if(episode["air_date"] != null) {
              airDate = new DateFormat.yMMMMd("en_US").format(
                  DateTime.parse(episode["air_date"])
              );
            }

            var card = new Card(
              color: backgroundColor,
              clipBehavior: Clip.antiAlias,
              elevation: 5.0, // Boost shadow...


              child: new Column(
                children: <Widget>[
                  _generateEpisodeImage(episode, _controller),

                  Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 5.0, left: 5.0, right: 5.0),
                      child: TitleText(episode["name"], fontSize: 28, allowOverflow: true, textAlign: TextAlign.center)
                  ),

                  Padding(
                      padding: EdgeInsets.only(bottom: 5.0, left: 5.0, right: 5.0),
                      child: TitleText(
                          '${episode["season_number"]}x${episode["episode_number"]} \u2022 $airDate',

                          fontSize: 18,
                          allowOverflow: true,
                          textAlign: TextAlign.center
                      )
                  ),

                  Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0, right: 20.0),
                      child: ConcealableText(
                        episode["overview"],
                        revealLabel: "Show more...",
                        concealLabel: "Show less...",

                        maxLines: 4
                      )
                  ),

                  new Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: new SizedBox(
                        width: double.infinity,
                        child: new Padding(
                          padding: EdgeInsets.only(top: 15.0, bottom: 20, left: 15.0, right: 15.0),
                          child: new SizedBox(
                            height: 40,
                            child: new RaisedButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0)
                                ),
                                onPressed: (){
                                  Interface.showAlert(
                                      context,
                                      new TitleText('Searching for Sources...'),
                                      [
                                        Center(
                                          child: Text("BETA NOTE: If you find yourself waiting more than 30 seconds, there's a good chance we don't have the content you're looking for."),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(top: 20),
                                            child: Center(
                                                child: new CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                                )
                                            )
                                        )
                                      ],
                                      false,
                                      [Container()]
                                  );

                                  int seasonNumber = episode["season_number"];
                                  int episodeNumber = episode["episode_number"];

                                  vendorConfigs[0].playTVShow(
                                      widget.showContentModel.title,
                                      widget.showContentModel.releaseDate,
                                      seasonNumber,
                                      episodeNumber,
                                      context
                                  );
                                },
                                child: new Text(
                                  "Play Episode",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'GlacialIndifference'
                                  ),
                                ),
                                color: primaryColor,

                                elevation: 1
                            ),
                          )
                        ),
                      )
                  )
                ],
              ),
            );

            const padding = 15.0;

            return Padding(
                padding: EdgeInsets.only(
                  // Cancel the effects of the status bar.
                    top: MediaQuery.of(context).padding.top + padding,
                    bottom: padding,
                    left: padding,
                    right: padding
                ),
                child: card
            );
          }
        )
    );
  }

  Widget _generateEpisodeImage(Map episode, ScrollController _controller){
    if (episode["still_path"] == null) {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints size) {
        return Center(
          child: new Parallax.inside(
              mainAxisExtent: 220.0,
              child: new Image.asset(
                "assets/images/no_image_detail.jpg",
                height: 300,
                width: size.maxWidth,
                fit: BoxFit.cover,
              )
          ),
        );
      });
    }

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints size){
      return Center(
        child: new Parallax.inside(
            mainAxisExtent: 200.0,
            child: new Image.network(
              "${tmdb.image_cdn}${episode["still_path"]}",
              height: 300,
              width: size.maxWidth,
              fit: BoxFit.cover,
            )
          // height: 220.0,
          // fit: BoxFit.cover,
        ),
      );
    });
  }

}

class SeasonModel {
  final int seasonNumber, id;
  final List episodes;
  final String airDate, name;

  SeasonModel(this.seasonNumber, this.id, this.name, this.episodes, this.airDate);

  SeasonModel.fromJson(Map json):
        id = json["id"],
        name = json["name"],
        seasonNumber = json["season_number"],
        airDate = json["air_date"],
        episodes = json["episodes"];
}