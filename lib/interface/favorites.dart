import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/res/BottomGradient.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:kamino/interface/content/overview.dart';

class FavoritesPage extends StatefulWidget {
  @override
  FavoritesPageState createState() => new FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {

  TabController _tabController;

  List<Map> _favTV = [];
  List<Map> _favMovie = [];

  bool _tvExpanded;
  bool _movieExpanded;

  _getFavorites() {
    // Get the favorite tv shows/ movies
    databaseHelper.getAllFaves().then((data) {

      if(mounted) setState(() {
        _favTV = data["tv"].reversed.toList();
        _favMovie = data["movie"].reversed.toList();
      });

    });
  }

  @override
  void initState() {
    _tvExpanded = true;
    _movieExpanded = true;

    //initialise the tab controller
    _tabController = new TabController(vsync: this, length: 2, initialIndex: 0);
    _getFavorites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          //sort the favorites into ascending or descending
          setState(() {
            _favTV = _favTV.reversed.toList();
            _favMovie = _favMovie.reversed.toList();
          });
        },
        child: Icon(Icons.sort),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 500));
          _getFavorites();
        },
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10, left: 15, right: 15),
                child: Column(children: <Widget>[
                  (_favTV.length > 0) ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(child: Container(
                        color: Colors.transparent,
                        child: Row(children: <Widget>[
                          SubtitleText(S.of(context).tv_shows),
                          Icon(_tvExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down)
                        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      ), onTap: () => setState(() => _tvExpanded = !_tvExpanded)),
                      _tvExpanded ? _buildTab("tv") : Container(),

                      Container(margin: EdgeInsets.symmetric(vertical: 10)),
                    ],
                  ) : Container(),

                  (_favMovie.length > 0) ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(child: Container(
                        color: Colors.transparent,
                        child: Row(children: <Widget>[
                          SubtitleText(S.of(context).movies),
                          Icon(_movieExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down)
                        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      ), onTap: () => setState(() => _movieExpanded = !_movieExpanded)),
                      _movieExpanded ? _buildTab("movie") : Container(),

                      Container(margin: EdgeInsets.symmetric(vertical: 10)),
                    ],
                  ) : Container(),
                ], crossAxisAlignment: CrossAxisAlignment.start),
              ),
            ],
          )
        )
      )
    );
  }

  Widget _buildTab(String mediaType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GridView.builder(
        physics: new NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 0.76
        ),
        itemCount: mediaType == "tv" ? _favTV.length : _favMovie.length,
        itemBuilder: (BuildContext context, int index) {
          var _favItem =
          (mediaType == "tv"
              ? _favTV[index]
              : _favMovie[index]);

          return Container(
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ContentOverview(
                            contentId: _tabController.index == 0
                                ? _favTV[index]["tmdbID"]
                                : _favMovie[index]["tmdbID"],
                            contentType: _tabController.index == 0
                                ? ContentType.TV_SHOW
                                : ContentType.MOVIE)));
              },
              splashColor: Colors.white,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Card(
                      elevation: 5.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: CachedNetworkImage(
                          imageUrl: _favItem["imageUrl"] != null ? TMDB.IMAGE_CDN + _favItem["imageUrl"] : "",
                          height: 725.0,
                          width: 500.0,
                          fit: BoxFit.cover,
                          placeholder: Center(
                              child: CircularProgressIndicator()
                          ),
                          errorWidget: new Icon(Icons.error),
                        ),
                      )),
                  Padding(
                      padding: EdgeInsets.all(3.5),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: BottomGradient(finalStop: 0.025))),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Padding(
                              padding: EdgeInsets.only(
                                  bottom: 2, left: 10, right: 10),
                              child: TitleText(
                                mediaType == "tv"
                                    ? _favTV[index]["name"]
                                    : _favMovie[index]["name"],
                                fontSize: 16,
                                textColor: Colors.white,
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  top: 0, bottom: 10, left: 10, right: 10),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                      mediaType == "tv"
                                          ? _favTV[index]["year"] != null
                                          ? _favTV[index]["year"]
                                          .toString()
                                          .substring(0, 4)
                                          : S.of(context).unknown
                                          : _favMovie[index]["year"] != null
                                          ? _favMovie[index]["year"]
                                          .toString()
                                          .substring(0, 4)
                                          : S.of(context).unknown,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white)),
                                  Icon(
                                    mediaType == 'tv'
                                        ? Icons.tv
                                        : Icons.local_movies,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                ],
                              ))
                        ],
                      ))
                ],
              ),
            ),
          );
        }),
    );
  }

  Widget _nothingFoundScreen() {
    const _paddingWeight = 18.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: _paddingWeight, right: _paddingWeight),
        child: Text(
          S.of(context).no_results_found,
          maxLines: 3,
          style: TextStyle(
              fontSize: 22.0,
              fontFamily: 'GlacialIndifference',
              color: Theme.of(context).primaryTextTheme.body1.color),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
