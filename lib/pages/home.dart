import 'package:cplayer/cplayer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino/pages/smart_search/smart_search.dart';
import 'package:kamino/partials/apollowidgets/home_customise.dart';
import 'package:kamino/res/BottomGradient.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/pages/launchpad/see_all_expanded_view.dart';
import 'package:kamino/view/settings/settings_prefs.dart' as settingsPref;
import 'package:kamino/pages/smart_search/search_results.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/view/content/overview.dart';
import 'package:kamino/pages/smart_search/search_results.dart';
import 'package:kamino/partials/poster.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/pages/launchpad/launchpad.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:kamino/partials/_todo_ignore_apollowidgets/movies/now_playing.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  bool _hideWelcomeCard = false;
  List<int> _favs = [];
  List<String> _userOptions = [];
  bool _hideDebugCard = false;

  @override
  void initState() {
    settingsPref.getBoolPref("welcomeCard").then((data) {
      setState(() {
        _hideWelcomeCard = data;
      });
    });

    settingsPref.getBoolPref("debugCard").then((data){
      setState(() {
        _hideDebugCard = data;
      });
    });

    settingsPref.getListPref("launchpadOptions").then((data) {
      for (int x = 0; x < data.length; x++) {
        _userOptions.add(data[x]);
      }
    });

    databaseHelper.getAllFavIDs().then((data) {
      data.forEach((int element) => _favs.add(element));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async{

        await Future.delayed(Duration(seconds: 2));

        databaseHelper.getAllFavIDs().then((data) {
          _favs.clear();
          data.forEach((int element) => _favs.add(element));
        });

        settingsPref.getBoolPref("welcomeCard").then((data) {
          _hideWelcomeCard = data;
        });

        settingsPref.getBoolPref("debugCard").then((data){
          _hideDebugCard = data;

          print("the dub value is... $data");
        });

        settingsPref.getListPref("launchpadOptions").then((data) {
          _userOptions.clear();
          setState(() {
            for (int x = 0; x < data.length; x++) {
              _userOptions.add(data[x]);
            }
          });
        });
      },
      color: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      child: Scrollbar(
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,

            children: <Widget>[

              _buildLaunchPad()
            ],
          ),
        ),
      ),
    );
  }

  List<String> _urlBuilder(String title) {
    String _header = "";
    String _mediaType = "";
    String _tv = "tv";
    String _movie = "movie";

    if (title == "Airing Today") {
      _header = "Airing Today";
      _mediaType = _tv;
    } else if (title == "On The Air") {
      _header = "On The Air";
      _mediaType = _tv;
    } else if (title == "Popular TV Shows") {
      _header = "Popular";
      _mediaType = _tv;
    } else if (title == "Top Rated TV Shows") {
      _header = "Top Rated";
      _mediaType = _tv;
    } else if (title == "Now Playing") {
      _header = "Now Playing";
      _mediaType = _movie;
    } else if (title == "Popular Movies") {
      _header = "Popular";
      _mediaType = _movie;
    } else if (title == "Top Rated Movies") {
      _header = "Top Rated";
      _mediaType = _movie;
    } else if (title == "Upcoming Movies") {
      _header = "Upcoming";
      _mediaType = _movie;
    }

    //formatting the string to comply with the tmdb api docs
    String _baseUrl =
        "${tmdb.root_url}/$_mediaType/${_header.replaceAll(" ", "_").toLowerCase()}${tmdb.defaultArguments}&page=1";

    return [_baseUrl, _mediaType, _header, title];
  }

  EdgeInsets _titlePaddingBuilder(String title) {
    double _leftPadding = 15.0;
    double _rightPadding = 0.0;

    if (title == "Airing Today") {
      _rightPadding = 153.0;
    } else if (title == "On The Air") {
      _rightPadding = 168.0;
    } else if (title == "Popular TV Shows") {
      _rightPadding = 111.0;
    } else if (title == "Top Rated TV Shows") {
      _rightPadding = 91.0;
    } else if (title == "Now Playing") {
      _rightPadding = 155.0;
    } else if (title == "Popular Movies") {
      _rightPadding = 132.0;
    } else if (title == "Top Rated Movies") {
      _rightPadding = 112.0;
    } else if (title == "Upcoming Movies") {
      _rightPadding = 113.0;
    }

    return EdgeInsets.only(left: _leftPadding, right: _rightPadding);
    ;
  }

  Future<List<SearchModel>> _getDiscoverData(String title) async {
    List<SearchModel> _data = [];
    Map _temp;

    http.Response _res = await http.get(_urlBuilder(title)[0]);
    _temp = jsonDecode(_res.body);

    if (_temp["results"] != null) {
      int total_pages = _temp["total_pages"];
      int resultsCount = _temp["results"].length;

      for (int x = 0; x < resultsCount; x++) {
        _data.add(SearchModel.fromJSON(_temp["results"][x], total_pages));
      }
    }

    return _data;
  }

  Widget _searchButton() {
    return Container(
      //margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
        child: new Material(
          elevation: 5,
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(100),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
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
                        color: Colors.grey),
                  ),
                ),
                new Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: new Icon(
                      Icons.search,
                      color: Colors.grey,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLaunchPad() {
    return Expanded(
      child: new ListView.builder(
          itemCount: _userOptions.length + 3,
          itemBuilder: (BuildContext context, int index) {

            if (index == 0){
              return Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: _searchButton(),
              );

            }else if (index == 1) {
              return Padding(
                padding: _hideWelcomeCard == false ?
                EdgeInsets.only(top: 0.0) : EdgeInsets.only(top: 5.0),
                child: _launchPadIntroCard(),
              );

            } else if (index == 2) {
              return Padding(
                padding: _hideDebugCard == false ?
                EdgeInsets.only(top: 0.0) : EdgeInsets.only(top: 5.0),
                child: _debugCard(),
              );

            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: _launchPadCard(_userOptions[index - 3]),
              );

            }

          }),
    );
  }

  Widget _launchPadIntroCard() {
    return _hideWelcomeCard == false
        ? HomeCustomiseWidget() : Container();
  }


  _openContentScreen(BuildContext context, int index, AsyncSnapshot snapshot, String title) {

    if (_urlBuilder(title)[1] == "tv") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ContentOverview(
                      contentId: snapshot.data[index].id,
                      contentType: ContentOverviewContentType.TV_SHOW )
          )
      );
    } else if (_urlBuilder(title)[1] == "movie"){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ContentOverview(
                      contentId: snapshot.data[index].id,
                      contentType: ContentOverviewContentType.MOVIE )
          )
      );
    }
  }

  _openSeeAll(BuildContext context, String title) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ExpandedCard(
              url: _urlBuilder(title)[0],
              title: _urlBuilder(title)[3],
              mediaType: _urlBuilder(title)[1],
            )
        )
    );
  }

  Widget _debugCard() {
    return _hideDebugCard == false ? Container(
        //margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: new Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
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
            ))) : Container();
  }

  Widget _launchPadCard(String title) {

    return title == null
        ? Container()
        : new Container(
            //margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: new Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
              elevation: 5.0,
              color: Theme.of(context).cardColor,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: _titlePaddingBuilder(title),
                        child: TitleText(title),
                      ),
                      FlatButton(
                        onPressed: (){
                          _openSeeAll(context, title);
                        },
                        child: Text("See All"),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 188.0,
                    //width: 130.0,
                    child: _launchPadListView(title),
                  )
                ],
              ),
            ),
          );
  }

  Widget _launchPadListView(String title) {
    return FutureBuilder<List<SearchModel>>(
      future: _getDiscoverData(
          title), // a previously-obtained Future<String> or null
      builder:
          (BuildContext context, AsyncSnapshot<List<SearchModel>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to start.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            );

          case ConnectionState.done:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else if (snapshot.hasData) {
              return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () => _openContentScreen(context, index, snapshot, title),
                      child: Padding(
                        padding: index == 0 ? EdgeInsets.only(left: 10.0, bottom: 8.0, right: 4.0)
                            : EdgeInsets.only(bottom: 8.0, right: 4.0),
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Card(
                                child: ClipRRect(
                                  borderRadius: new BorderRadius.circular(5.0),
                                  child: _launchPoster(snapshot, index, title),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
        }
        return null; // unreachable
      },
    );
  }

  Widget _launchPoster(AsyncSnapshot snapshot, int index, String title) {
    var releaseYear = "";
    if (snapshot.data[index].year != null) {
      try {
        releaseYear = new DateFormat.y("en_US")
            .format(DateTime.parse(snapshot.data[index].year));
      } catch (ex) {
        releaseYear = "Unknown";
      }
    }

    if (releaseYear != "Unknown") {
      releaseYear.substring(0, 4);
    }

    return SizedBox(
      height: 170.0,
      width: 122.0,
      child: Container(
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            snapshot.data[index].poster_path != null
                ? CachedNetworkImage(
                    imageUrl:
                        "${tmdb.image_cdn}" + snapshot.data[index].poster_path,
                    fit: BoxFit.fill,
                    height: 172.0,
                    width: 120.0,
                    errorWidget: Image.asset(
                      "assets/images/no_image_detail.jpg",
                      fit: BoxFit.fill,
                      width: 172.0,
                      height: 120.0,
                    ),
                    placeholder: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Image.asset(
                    "assets/images/no_image_detail.jpg",
                    fit: BoxFit.fill,
                    width: 172.0,
                    height: 120.0,
                  ),
            SizedBox(
              height: 172.0,
              width: 120.0,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: BottomGradient(finalStop: 0.025)),
            ),
            SizedBox(
              height: 172.0,
              width: 120.0,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Padding(
                          padding:
                              EdgeInsets.only(bottom: 2, left: 10, right: 10),
                          child: TitleText(
                            snapshot.data[index].name,
                            fontSize: 16,
                            textColor: _favouriteIndicator(snapshot, index),
                          )),
                      Padding(
                          padding: EdgeInsets.only(
                              top: 0, bottom: 10, left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(releaseYear,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: _favouriteIndicator(
                                          snapshot, index))),
                              Icon(
                                _urlBuilder(title)[1] == 'tv'
                                    ? Icons.tv
                                    : Icons.local_movies,
                                size: 16,
                                color: _favouriteIndicator(snapshot, index),
                              )
                            ],
                          )),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Color _favouriteIndicator(AsyncSnapshot snapshot, int index) {
    if (_favs.contains(snapshot.data[index].id)) {
      return Colors.yellow;
    }

    return Theme.of(context).accentTextTheme.body1.color;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
