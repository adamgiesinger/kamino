import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/api/trakt.dart';
import 'package:kamino/interface/content/overview.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/partials/content_card.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/ui/interface.dart';
import 'package:simple_moment/simple_moment.dart';

class Launchpad2 extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => Launchpad2State();

}

class Launchpad2State extends State<Launchpad2> {

  //final AsyncMemoizer<List<ContentModel>> _topBannerMemoizer = AsyncMemoizer();
  //final AsyncMemoizer<List<ContentModel>> _continueWatchingMemoizer = AsyncMemoizer();

  List<ContentModel> _topPicksList = List();
  List<ContentModel> _continueWatchingList;

  Future<void> load() async {
    _topPicksList = (await TMDB.getList("107032")).content;

    if(await Trakt.isAuthenticated()) {
      _continueWatchingList = await Trakt.getWatchHistory(context);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: load(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.none || snapshot.hasError){
          if(snapshot.error is SocketException
            || snapshot.error is HttpException) return OfflineMixin();

          return Container(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.error, size: 48, color: Colors.grey),
                  Container(padding: EdgeInsets.symmetric(vertical: 10)),
                  TitleText("An error occurred.", fontSize: 24),
                  Container(padding: EdgeInsets.symmetric(vertical: 3)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      "Well this is awkward... An error occurred whilst loading your homepage.",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }

        switch(snapshot.connectionState){
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor
                ),
              ),
            );
          case ConnectionState.done:
          return ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                color: Theme.of(context).backgroundColor,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[

                  // ApolloTV Top Picks
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    height: 200,
                    child: Container(
                      child: ScrollConfiguration(
                          behavior: EmptyScrollBehaviour(),
                          child: CarouselSlider(
                              /* autoPlay: true,
                              autoPlayInterval: Duration(seconds: 20),
                              autoPlayAnimationDuration: Duration(milliseconds: 1400), */
                              enlargeCenterPage: true,
                              height: 200,
                              items: List.generate(_topPicksList.length, (int index){
                                return Builder(builder: (BuildContext context){
                                  var content = _topPicksList[index];

                                  return Container(
                                    child: ContentCard(content),
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                  );
                                });
                              })
                          )
                      ),
                    ),
                  ),

                  _continueWatchingList != null ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("CONTINUE WATCHING", style: TextStyle(
                          fontFamily: 'GlacialIndifference',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Theme.of(context).primaryTextTheme.display3.color,
                        )),

                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: _continueWatchingList.length,
                            itemBuilder: (BuildContext context, int index){
                              return GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ContentOverview(
                                        contentId: _continueWatchingList[index].id,
                                        contentType: _continueWatchingList[index].contentType
                                      )
                                    )
                                  );
                                },
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  color: Theme.of(context).cardColor,
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        leading: CachedNetworkImage(
                                          imageUrl: TMDB.IMAGE_CDN + _continueWatchingList[index].posterPath,
                                          height: 92,
                                          width: 46,
                                        ),
                                        title: TitleText(_continueWatchingList[index].title),
                                        subtitle: Text("${(_continueWatchingList[index].progress * 100).round()}% watched \u2022 ${DateTime.parse(_continueWatchingList[index].lastWatched).isAfter(DateTime.now()) ? "watching now" : Moment.now().from(DateTime.parse(_continueWatchingList[index].lastWatched))}"),
                                      ),

                                      SizedBox(
                                        height: 4,
                                        width: double.infinity,
                                        child: LinearProgressIndicator(
                                            value: _continueWatchingList[index].progress,
                                            backgroundColor: const Color(0x22000000),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).primaryColor
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          ),
                        )
                      ],
                    ),
                  ) : Container()

                ]),
              )
            ],
          );
        }
      }
    );
  }

}