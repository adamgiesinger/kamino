import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/res/BottomGradient.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:kamino/ui/ui_constants.dart';
import 'package:kamino/view/content/overview.dart';

class FavoritesPage extends StatefulWidget {
  @override
  FavoritesPageState createState() => new FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {

  TabController _tabController;

  List<Map> _favTV = [];
  List<Map> _favMovie = [];

  _getFavs() {
    // Get the favourite tv shows/ movies
    databaseHelper.getAllFaves().then((data) {

      setState(() {
        _favTV = data["tv"].reversed.toList();
        _favMovie = data["movie"].reversed.toList();
      });

    });
  }

  @override
  void initState() {
    //initialise the tab controller
    _tabController = new TabController(vsync: this, length: 2, initialIndex: 0);

    _getFavs();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    TextStyle _glacialFont = TextStyle(
        fontFamily: "GlacialIndifference");

    return Scaffold(
      appBar: new AppBar(
          title: Text("Favorites", style: _glacialFont,),
          centerTitle: true,
          backgroundColor: Theme.of(context).backgroundColor,
          actions: <Widget>[
            generateSearchIcon(context),

            IconButton(
              icon: Icon(Icons.sort),
              onPressed: () {
                //sort the favourites into ascending or descending
                setState(() {
                  _favTV = _favTV.reversed.toList();
                  _favMovie = _favMovie.reversed.toList();
                });
              },
              )
            ],
          bottom: new TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 2.4,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.tv),
              ),
              Tab(
                icon: Icon(Icons.local_movies),
              ),
            ],
          )),
        body: TabBarView(
          controller: _tabController,
            children: [
              _favTV.length == 0 ? _nothingFoundScreen() : _buildTab("tv"),
              _favMovie.length == 0 ? _nothingFoundScreen() : _buildTab("movie")
            ],
          ),
    );
  }

  Widget _buildTab(String mediaType) {
    return RefreshIndicator(
      onRefresh: () async {

        await Future.delayed(Duration(seconds: 2));
        _getFavs();
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 0.76),
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
                              imageUrl: _favItem["imageUrl"] != null ? image_cdn + _favItem["imageUrl"] : "",
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
                                              : "Unknown"
                                              : _favMovie[index]["year"] != null
                                              ? _favMovie[index]["year"]
                                              .toString()
                                              .substring(0, 4)
                                              : "Unknown",
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
      ),
    );
  }

  Widget _nothingFoundScreen() {
    const _paddingWeight = 18.0;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.only(left: _paddingWeight, right: _paddingWeight),
        child: Text(
          "Nothing here yet...",
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
