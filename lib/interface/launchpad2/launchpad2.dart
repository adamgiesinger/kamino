import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/api/trakt.dart';
import 'package:kamino/interface/content/overview.dart';
import 'package:kamino/main.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/partials/carousel.dart';
import 'package:kamino/partials/content_card.dart';
import 'package:kamino/partials/content_poster.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/ui/interface.dart';
import 'package:simple_moment/simple_moment.dart';

class Launchpad2 extends KaminoAppPage {

  @override
  State<StatefulWidget> createState() => Launchpad2State();

}

class Launchpad2State extends State<Launchpad2> with AutomaticKeepAliveClientMixin<Launchpad2> {

  AsyncMemoizer _memoizer = new AsyncMemoizer();

  EditorsChoice _editorsChoice;
  List<ContentModel> _topPicksList = List();
  List<ContentModel> _continueWatchingList;

  Future<void> load() async {
    // Randomly select a choice from the Editor's Choice list.
    var editorsChoiceComments = jsonDecode((await TMDB.getList(context, "109986", loadFully: false, raw: true)))['comments'] as Map;
    List<ContentModel> editorsChoiceList = (await TMDB.getList(context, "109986", loadFully: true)).content;

    var selectedChoice = (editorsChoiceList[Random().nextInt(editorsChoiceList.length)]);
    _editorsChoice = new EditorsChoice(
      id: selectedChoice.id,
      title: selectedChoice.title,
      poster: selectedChoice.posterPath,
      type: selectedChoice.contentType,
      comment: editorsChoiceComments['${getRawContentType(selectedChoice.contentType)}:${selectedChoice.id}']
    );

    _topPicksList = (await TMDB.getList(context, "107032")).content;

    if(await Trakt.isAuthenticated()) {
      _continueWatchingList = await Trakt.getWatchHistory(context);
    }
    
    updateKeepAlive();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: _memoizer.runOnce(load),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.none || snapshot.hasError){
          if(snapshot.error is SocketException
            || snapshot.error is HttpException) return OfflineMixin(
            reloadAction: () async {
              _memoizer = new AsyncMemoizer();
              await _memoizer.runOnce(load).catchError((error){});
              setState(() {});
            },
          );

          return ErrorLoadingMixin(errorMessage: "Well this is awkward... An error occurred whilst loading your launchpad.");
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
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 20),
                              autoPlayAnimationDuration: Duration(milliseconds: 1400),
                              pauseAutoPlayOnTouch: Duration(seconds: 1),
                              enlargeCenterPage: true,
                              height: 200,
                              items: List.generate(_topPicksList.length, (int index){
                                return Builder(builder: (BuildContext context){
                                  var content = _topPicksList[index];

                                  return Container(
                                    child: ContentCard(content, keepAlive: true),
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                  );
                                });
                              })
                          )
                      ),
                    ),
                  ),

                  SubtitleText("Editor's Choice", padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10).copyWith(bottom: 0)),
                  Container(
                      height: 200,
                      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Card(
                              child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
                                return Container(
                                  margin: EdgeInsets.only(left: 107),
                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      TitleText(
                                          _editorsChoice.title,
                                          fontSize: 24
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 10, right: 5),
                                        child: Text(
                                          _editorsChoice.comment,
                                          overflow: TextOverflow.fade,
                                          maxLines: 5,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              })
                            ),
                          ),

                          Positioned(
                            top: 0,
                            left: 0,
                            bottom: 0,
                            width: 107,
                            child: ContentPoster(
                              elevation: 4,
                              onTap: () => Interface.openOverview(context, _editorsChoice.id, _editorsChoice.type),
                              background: _editorsChoice.poster,
                              showGradient: false,
                            ),
                          )
                        ],
                      )
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
                  ) : Container(),

                ]),
              )
            ],
          );
        }
      }
    );
  }

  @override
  bool get wantKeepAlive => true;

}

class EditorsChoice {

  int id;
  ContentType type;
  String title;
  String comment;
  String poster;

  EditorsChoice({
    @required this.id,
    @required this.type,
    @required this.title,
    @required this.comment,
    @required this.poster
  });

}