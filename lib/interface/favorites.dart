import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/partials/content_poster.dart';
import 'package:kamino/res/BottomGradient.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/ui/interface.dart';
import 'package:kamino/util/databaseHelper.dart';
import 'package:kamino/interface/content/overview.dart';

class FavoritesPage extends StatefulWidget {
  @override
  FavoritesPageState createState() => new FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {

  Map<String, List<FavoriteDocument>> favorites;
  bool tvExpanded;
  bool movieExpanded;

  _getFavorites() async {
    favorites = await DatabaseHelper.getAllFavorites();
    setState(() {});
  }

  @override
  void initState() {
    tvExpanded = true;
    movieExpanded = true;

    _getFavorites();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(favorites == null){
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor
          ),
        ),
      );
    }

    // If every sublist in favorites is empty, the user has no favorites.
    if(favorites.values.every((List subList) => subList.isEmpty)){
      return noFavoritesWidget();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          setState(() {
            for(var subList in favorites.values){
              subList = subList.reversed.toList();
            }
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
                  (favorites['tv'].length > 0) ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(child: Container(
                        color: Colors.transparent,
                        child: Row(children: <Widget>[
                          SubtitleText(S.of(context).tv_shows),
                          Icon(tvExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down)
                        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      ), onTap: () => setState(() => tvExpanded = !tvExpanded)),
                      tvExpanded ? _buildSection(ContentType.TV_SHOW) : Container(),

                      Container(margin: EdgeInsets.symmetric(vertical: 10)),
                    ],
                  ) : Container(),

                  (favorites['movie'].length > 0) ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(child: Container(
                        color: Colors.transparent,
                        child: Row(children: <Widget>[
                          SubtitleText(S.of(context).movies),
                          Icon(movieExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down)
                        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      ), onTap: () => setState(() => movieExpanded = !movieExpanded)),
                      movieExpanded ? _buildSection(ContentType.MOVIE) : Container(),

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

  Widget _buildSection(ContentType type) {
    var sectionList = favorites[getRawContentType(type)];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: GridView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        physics: new NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 0.66,
          mainAxisSpacing: 10, crossAxisSpacing: 10
        ),
        itemCount: sectionList.length,
        itemBuilder: (BuildContext context, int index) {
          var favorite = sectionList[index];
          return ContentPoster(
            background: favorite.imageUrl,
            name: favorite.name,
            releaseYear: favorite.year,
            mediaType: getRawContentType(type),
            onTap: () => Interface.openOverview(context, favorite.tmdbId, type),
            elevation: 4,
            hideIcon: true,
          );
        }),
    );
  }

  Widget noFavoritesWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.favorite_border, size: 64),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: TitleText(
                S.of(context).no_favorites_header,
                fontSize: 28,
              ),
            ),
            Text(
              S.of(context).no_favorites_description,
              textAlign: TextAlign.center
            )
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}
