import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  SeasonModel _data;

  @override
  void initState() {
    // When the widget is initialized, download the overview data.
    loadDataAsync().then((data) {
      // When complete, update the state which will allow us to
      // draw the UI.
      setState(() {
        _data = data;
      });
    });

    super.initState();
  }

  // Load the data from the source.
  Future<SeasonModel> loadDataAsync() async {
    String url = "${tmdb.root_url}/tv/${widget.contentId}/season/"
        "${widget.seasonIndex}${tmdb.default_arguments}";

    http.Response response  = await http.get(url);

    var _json = jsonDecode(response.body);
    return new SeasonModel(_json["season_number"],
        _json["id"], _json["episodes"], _json["air_date"]);
  }

  /* THE FOLLOWING CODE IS JUST LAYOUT CODE. */

  @override
  Widget build(BuildContext context) {
    // This is shown whilst the data is loading.
    if (_data == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                  Theme
                      .of(context)
                      .primaryColor
              ),
            )
        )
      );
    }

    // When the data has loaded we can display the general outline and content-type specific body.
    return new Scaffold(
      backgroundColor: backgroundColor,
      body: PageView(
        children: _data.episodes.map((episode) {
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

                _generateEpisodeImage(episode),

                Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 5.0, left: 5.0, right: 5.0),
                  child: TitleText(episode["name"], fontSize: 28, allowOverflow: true, textAlign: TextAlign.center)
                ),

                Padding(
                    padding: EdgeInsets.only(bottom: 40.0, left: 5.0, right: 5.0),
                    child: TitleText(
                      '${episode["season_number"]}x${episode["episode_number"]} \u2022 $airDate',

                      fontSize: 18,
                      allowOverflow: true,
                      textAlign: TextAlign.center
                    )
                ),

                Expanded(
                  flex: 3,
                  child: new SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(episode["overview"])
                    )
                  )
                ),

                // Bottom button - Play
                new Expanded(
                  child: new Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: new SizedBox(
                      width: double.infinity,
                      child: new Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                        child: new MaterialButton(
                          onPressed: (){

                            Interface.showAlert(
                                context,
                                new TitleText('Searching for Sources...'),
                                [
                                  Center(
                                    child: Text("BETA NOTE: If you find yourself waiting more than 15 seconds, there's a good chance we're experiencing server issues."),
                                  ),
                                  Center(
                                      child: new CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
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
                              context,
                              replaceNavigatorContext: true
                            );
                          },
                          child: new Text("Play Episode"),
                          color: primaryColor,

                          height: 40
                        )
                      ),
                    )
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
        }).toList()
      )
    );
  }

  Widget _generateEpisodeImage(Map episode){

    if (episode["still_path"] == null) {
      return Center(
        child: Image.asset(
          "assets/images/no_image_detail.jpg",
          height: 220.0,
          fit: BoxFit.cover,
        ),
      );
    }

    return Center(
      child: new Image(
        image: NetworkImage(
          "http://image.tmdb.org/t/p/w500"+
              episode["still_path"]
        ),
        height: 220.0,
        fit: BoxFit.cover,
      ),
    );
  }

}

class SeasonModel {
  final int seasonNumber, id;
  final List episodes;
  final String airDate;

  SeasonModel(this.seasonNumber, this.id, this.episodes, this.airDate);

  SeasonModel.fromJson(Map json):
        id = json["id"],
        seasonNumber = json["season_number"],
        airDate = json["air_date"],
        episodes = json["episodes"];
}