import 'package:async/async.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/interface/favorites.dart';
import 'package:kamino/interface/genre/all_genres.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/partials/content_card.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/util/interface.dart';
// import 'package:preload_page_view/preload_page_view.dart';

class Launchpad2 extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => Launchpad2State();

}

class Launchpad2State extends State<Launchpad2> {

  final AsyncMemoizer<List<ContentModel>> _memoizer = AsyncMemoizer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Theme.of(context).backgroundColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[

        // ApolloTV Top Picks
        Container(
          margin: EdgeInsets.only(bottom: 20),
          height: 200,
          child: FutureBuilder<List<ContentModel>>(future: _memoizer.runOnce(() => TMDB.getList("107032")), builder: (BuildContext context, AsyncSnapshot<List<ContentModel>> snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              if(snapshot.hasError) return Container(child: Text(snapshot.error.toString()));

              List<ContentModel> contentList = snapshot.data;

              return Container(
                child: ScrollConfiguration(
                  behavior: EmptyScrollBehaviour(),
                  //child: PreloadPageView.builder(itemBuilder: (BuildContext context, int index){
                  /*
                  var content = contentList[index];

                    return Container(
                      child: ContentCard(content),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding: EdgeInsets.symmetric(vertical: 10),
                    );
                   */
                  //}, itemCount: contentList.length, scrollDirection: Axis.horizontal),
                  child: CarouselSlider(
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 20),
                    autoPlayAnimationDuration: Duration(milliseconds: 1400),
                    enlargeCenterPage: true,
                    height: 200,
                    items: List.generate(contentList.length, (int index){
                      return Builder(builder: (BuildContext context){
                        var content = contentList[index];

                        return Container(
                          child: ContentCard(content),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          padding: EdgeInsets.symmetric(vertical: 10),
                        );
                      });
                    })

                  )
                ),
              );
            }

            return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                )
            );
          }),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            VerticalIconButton(
              title: TitleText("TV Shows"),
              icon: Icon(Icons.live_tv),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => AllGenres(contentType: 'tv')
              )),
              borderRadius: BorderRadius.circular(10),
            ),

            VerticalIconButton(
              title: TitleText("Favorites"),
              icon: Icon(Icons.favorite),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => FavoritesPage()
              )),
              borderRadius: BorderRadius.circular(10),
            ),

            VerticalIconButton(
              title: TitleText("Movies"),
              icon: Icon(Icons.local_movies),
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => AllGenres(contentType: 'movie')
              )),
              borderRadius: BorderRadius.circular(10),
            )
          ],
        )

      ]),
    );
  }

}