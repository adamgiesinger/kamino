import 'dart:async';
import 'dart:convert' as Convert;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:kamino/api/trakt.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/models/movie.dart';
import 'package:kamino/models/tvshow.dart';

import 'package:kamino/api/tmdb.dart';
import 'package:kamino/res/BottomGradient.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/util/trakt.dart' as trakt;
import 'package:kamino/interface/genre/genreResults.dart';
import 'package:kamino/interface/content/movieLayout.dart';
import 'package:kamino/interface/content/tvShowLayout.dart';

import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:transparent_image/transparent_image.dart';

/*  CONTENT OVERVIEW WIDGET  */
///
/// The ContentOverview widget allows you to show information about Movie or TV show.
///
class ContentOverview extends StatefulWidget {
  final int contentId;
  final ContentType contentType;

  ContentOverview(
      {Key key, @required this.contentId, @required this.contentType})
      : super(key: key);

  @override
  _ContentOverviewState createState() => new _ContentOverviewState();
}

///
/// _ContentOverviewState is completely independent of the content type.
/// In the widget build section, you can add a reference to the body layout for your content type.
/// _data will be a ContentModel. You should look at an example model to cast this to your content type.
///
class _ContentOverviewState extends State<ContentOverview> {

  TextSpan _titleSpan = TextSpan();
  bool _longTitle = false;
  String _backdropImagePath;
  bool _favState = false;
  List<int> _favIDs = [];
  String _contentType;

  Widget _override;
  ContentModel _data;
  String _trailer;
  List crew;
  List cast;

  Widget _generateFavoriteIcon(bool state){

    Widget _result;

    if(state == true) {

      _result = Icon(
        Icons.favorite,
        color: Colors.red,
      );

    } else {

      _result = Icon(
        Icons.favorite_border,
        color: Theme.of(context).primaryTextTheme.body1.color,
      );
    }

    return _result;
  }


  @override
  void initState() {

    //check if the show is a favorite

    widget.contentType == ContentType.MOVIE ?
    _contentType = "movie" : _contentType = "tv";

    databaseHelper.getAllFavIDs().then((data) {
      if (!this.mounted) return;

      setState(() {
        _favIDs = data;
        _favState = data.contains(widget.contentId);
      });
    });

    // When the widget is initialized, download the overview data.
    try {
      loadDataAsync().then((data) {
        if (!this.mounted) return;

        // When complete, update the state which will allow us to
        // draw the UI.
        setState(() {
          _data = data;

          _titleSpan = new TextSpan(
              text: _data.title,
              style: TextStyle(
                  fontFamily: 'GlacialIndifference',
                  fontSize: 19,
                  color: Theme
                      .of(context)
                      .primaryTextTheme
                      .title
                      .color
              )
          );

          var titlePainter = new TextPainter(
              text: _titleSpan,
              maxLines: 1,
              textAlign: TextAlign.start,
              textDirection: Directionality.of(context)
          );

          titlePainter.layout(maxWidth: MediaQuery
              .of(context)
              .size
              .width - 160);
          _longTitle = titlePainter.didExceedMaxLines;
        });
      }).catchError((error){
        _override = OfflineMixin();
      });
    }catch(_){
      return;
    }

    super.initState();
  }

  // Load the data from the source.
  Future<ContentModel> loadDataAsync() async {
    // Load trailer
    http.Response videosRawResponse = await http.get(
      "${TMDB.ROOT_URL}/${widget.contentType == ContentType.MOVIE ? 'movie' : 'tv'}/${widget.contentId}/videos${TMDB.defaultArguments}"
    );
    List<dynamic> videos = Convert.jsonDecode(videosRawResponse.body)['results'];
    if(videos != null && videos.isNotEmpty && videos.where((video) => video['type'] == 'Trailer').length > 0) {
      var video = videos.firstWhere((video) => video['type'] == 'Trailer');
      _trailer = video != null ? video['key'] : null;
    }

    // Load cast & crew
    var castCrewResponse = Convert.jsonDecode((await http.get(
      "${TMDB.ROOT_URL}/${widget.contentType == ContentType.MOVIE ? 'movie' : 'tv'}/${widget.contentId}/credits${TMDB.defaultArguments}"
    )).body);
    cast = castCrewResponse["cast"] != null ? castCrewResponse["cast"] : [];
    crew = castCrewResponse["crew"] != null ? castCrewResponse["crew"] : [];

    if(widget.contentType == ContentType.MOVIE){

      // Get the data from the server.
      http.Response response = await http.get(
        "${TMDB.ROOT_URL}/movie/${widget.contentId}${TMDB.defaultArguments}"
      );
      String json = response.body;

      // Get the recommendations data from the server.
      http.Response recommendedDataResponse = await http.get(
        "${TMDB.ROOT_URL}/movie/${widget.contentId}/similar${TMDB.defaultArguments}&page=1"
      );
      String recommended = recommendedDataResponse.body;

      // Return movie content model.
      return MovieContentModel.fromJSON(
          Convert.jsonDecode(json),
          recommendations: Convert.jsonDecode(recommended)["results"]
      );

    }else if(widget.contentType == ContentType.TV_SHOW){

      // Get the data from the server.
      http.Response response = await http.get(
          "${TMDB.ROOT_URL}/tv/${widget.contentId}${TMDB.defaultArguments}"
      );
      String json = response.body;

      // Return TV show content model.
      return TVShowContentModel.fromJSON(Convert.jsonDecode(json));
    }

    throw new Exception("Unexpected content type.");
  }

  //Logic for the favorites button
  _favButtonLogic(BuildContext context) async {

    if (_favState == true) {

      //remove the show from the database
      databaseHelper.removeFavorite(widget.contentId);

      if(await Trakt.isAuthenticated()) trakt.removeMedia(
          context,
          widget.contentType == ContentType.TV_SHOW ? "tv" : "movie",
          widget.contentId
      );

      //show notification snackbar
      Interface.showSnackbar(S.of(context).removed_from_favorites, context: context, backgroundColor: Colors.red);

      //set fav to false to reflect change
      setState(() {
        _favState = false;
      });

    } else if (_favState == false){

      //add the show to the database
      databaseHelper.saveFavorites(
          _data.title,
          widget.contentType == ContentType.TV_SHOW ? "tv" : "movie",
          widget.contentId,
          _data.posterPath,
          _data.releaseDate);

      if(await Trakt.isAuthenticated()) trakt.sendNewMedia(
          context,
          widget.contentType == ContentType.TV_SHOW ? "tv" : "movie",
          _data.title,
          _data.releaseDate != null ? _data.releaseDate.substring(0,4) : null,
          widget.contentId);

      //show notification snackbar
      Interface.showSnackbar(S.of(context).added_to_favorites, context: context);

      //set fav to true to reflect change
      setState(() {
        _favState = true;
      });
    }
  }

  /* THE FOLLOWING CODE IS JUST LAYOUT CODE. */

  @override
  Widget build(BuildContext context) {

    // If the content is overriden by a widget, that widget will be shown.
    // This is primarily used for error messages.
    if(_override != null) return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: _override
    );

    // This is shown whilst the data is loading.
    if (_data == null) return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor
          ),
        )
      )
    );

    // When the data has loaded we can display the general outline and content-type specific body.
    return new Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        children: <Widget>[
          NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    backgroundColor: Theme.of(context).backgroundColor,
                    actions: <Widget>[

                      Interface.generateSearchIcon(context),

                      IconButton(
                        icon: _generateFavoriteIcon(_favState),
                        onPressed: (){
                          _favButtonLogic(context);
                        },
                      ),
                    ],
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: LayoutBuilder(builder: (context, size){
                        var titleTextWidget = new RichText(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          text: _titleSpan,
                        );

                        if(_longTitle) return Container();

                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: size.maxWidth - 160
                          ),
                          child: titleTextWidget
                        );
                      }),
                      background: _generateBackdropImage(context),
                      collapseMode: CollapseMode.pin,
                    ),
                  )
                ];
              },
              body: Container(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (notification){
                      if(notification.leading){
                        notification.disallowGlow();
                      }
                    },
                    child: ListView(

                        children: <Widget>[
                          // This is the summary line, just below the title.
                          _generateOverviewWidget(context),

                          // Content Widgets
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Column(
                                children: <Widget>[
                                  /*
                                  * If you're building a row widget, it should have a horizontal
                                  * padding of 24 (narrow) or 16 (wide).
                                  *
                                  * If your row is relevant to the last, use a vertical padding
                                  * of 5, otherwise use a vertical padding of 5 - 10.
                                  *
                                  * Relevant means visually and by context.
                                  */
                                  //_generateGenreChipsRow(context),
                                  _generateSynopsisSection(),
                                  _generateCastAndCrewInfo(),

                                  // Context-specific layout
                                  _generateLayout(widget.contentType)
                                ],
                              )
                          )
                        ]
                    ),
                  )
              )
          ),

          Positioned(
            left: -7.5,
            right: -7.5,
            bottom: 30,
            child: Container(
              child: _getFloatingActionButton(
                widget.contentType,
                context,
                _data
              )
            ),
          )
        ],
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling
    );
  }

  ///
  /// OverviewWidget -
  /// This is the summary line just below the title.
  ///
  Widget _generateOverviewWidget(BuildContext context){
    return new Padding(
      padding: EdgeInsets.only(bottom: 5.0, left: 30, right: 30),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _longTitle ? Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: TitleText(
                _data.title,
                allowOverflow: true,
                textAlign: TextAlign.center,
                fontSize: 23,
              ),
            ) : Container(),

            Text(
                _data.releaseDate != "" && _data.releaseDate != null ?
                  "${S.of(context).released}: ${DateTime.parse(_data.releaseDate).year.toString()}" :
                  S.of(context).unknown_x(S.of(context).year),
                style: TextStyle(
                    fontFamily: 'GlacialIndifference',
                    fontSize: 16.0
                )
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                StarRating(
                  rating: _data.rating / 2, // Ratings are out of 10 from our source.
                  color: Theme.of(context).primaryColor,
                  borderColor: Theme.of(context).primaryColor,
                  size: 16.0,
                  starCount: 5,
                ),
                Text(
                  "  \u2022  ${S.of(context).n_ratings(_data.voteCount.toString())}",
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold
                  )
                )
              ],
            )
          ]
      ),
    );
  }

  ///
  /// BackdropImage (Subwidget) -
  /// This controls the background image and stacks the gradient on top
  /// of the image.
  ///
  Widget _generateBackdropImage(BuildContext context){
    double contextWidth = MediaQuery.of(context).size.width;

    //null trap to private slow urls crashing the screen
    // (big issue with some old and foreign shows)
    _data.backdropPath != null ?
    _backdropImagePath = TMDB.IMAGE_CDN + _data.backdropPath :
    _backdropImagePath = TMDB.IMAGE_CDN;

    return Container(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Container(
              child: _data.backdropPath != null ?
              CachedNetworkImage(
                imageUrl: _backdropImagePath,
                fit: BoxFit.cover,
                placeholder: Container(),
                height: 220.0,
                width: contextWidth,
                errorWidget: new Icon(Icons.error, size: 30.0)
              ) :
              new Icon(Icons.error, size: 30.0)
          ),

          !_longTitle ?
          BottomGradient(color: Theme.of(context).backgroundColor)
              : BottomGradient(offset: 1, finalStop: 0, color: Theme.of(context).backgroundColor),

          _trailer != null ? Center(child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 1.5
              ),
              shape: BoxShape.circle
            ),
            child: Material(
              color: const Color(0x1F000000),
              clipBehavior: Clip.antiAlias,
              shape: CircleBorder(),
              child: InkWell(
                onTap: (){
                  Interface.launchURL("https://www.youtube.com/watch?v=$_trailer");
                },
                child: Padding(child: Icon(
                  Icons.play_arrow,
                  size: 36,
                ), padding: EdgeInsets.all(4)),
              ),
            ),
          )) : Container()
        ],
      ),
    );
  }

  ///
  /// GenreChipsRowWidget -
  /// This is the row of purple genre chips.
  _loadMoreGenreMatches(String mediaType, int id, String genreName) {
    if (mediaType == "tv"){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  GenreView(
                      contentType: "tv",
                      genreID: id,
                      genreName: genreName )
          )
      );
    } else if (mediaType == "movie"){
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  GenreView(
                      contentType: "movie",
                      genreID: id,
                      genreName: genreName )
          )
      );
    }
  }

  Widget _generateGenreChipsRow(context){
    return _data.genres == null ? Container() : SizedBox(
      width: MediaQuery.of(context).size.width,
      //height: 40.0,
      child: Container(
        child: Center(
          // We want the chips to overflow.
          // This can't seem to be done with a ListView.
          child: Builder(builder: (BuildContext context){
            var chips = <Widget>[];

            for(int index = 0; index < _data.genres.length; index++){
              chips.add(
                  Container(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: (){
                        _loadMoreGenreMatches(_contentType,
                            _data.genres[index]["id"], _data.genres[index]["name"]);
                      },
                      child: Padding(
                        padding: index != 0
                            ? EdgeInsets.only(left: 6.0, right: 6.0)
                            : EdgeInsets.only(left: 6.0, right: 6.0),
                        child: new Chip(
                          label: Text(
                            _data.genres[index]["name"],
                            style: TextStyle(color: Theme.of(context).accentTextTheme.body1.color, fontSize: 15.0),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
              );
            }

            return Wrap(
              alignment: WrapAlignment.center,
              children: chips,
            );
          }),

        )
      )
    );
  }

  ///
  /// This function generates the Synopsis Card.
  ///
  Widget _generateSynopsisSection(){
    return Padding(
      padding: EdgeInsets.only(top: 0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          /*SubtitleText(
            S.of(context).synopsis,
          ),*/
          Container(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
            child: ConcealableText(
              _data.overview != "" ?
                _data.overview :
                // e.g: 'This TV Show has no synopsis available.'
                S.of(context).this_x_has_no_synopsis_available(getOverviewContentTypeName(widget.contentType)),

              maxLines: 3,
              revealLabel: S.of(context).show_more,
              concealLabel: S.of(context).show_less,
              color: const Color(0xFFBCBCBC)
            )
          )
        ],
      ),
    );
  }
  
  ///
  /// This function generates the cast and crew cards.
  /// 
  Widget _generateCastAndCrewInfo({bool emptyOnFail = true}){
    if(emptyOnFail && (cast == null || crew == null || cast.isEmpty || crew.isEmpty))
      return Container();

    List castAndCrew = List.from(crew.length > 3 ? crew.sublist(0, 3) : crew, growable: true);
    castAndCrew.addAll(cast);

    // Remove any with an invalid name, job/character, profile
    castAndCrew.removeWhere((entry) => entry["name"] == null);
    castAndCrew.removeWhere((entry) => entry["job"] == null && entry["character"] == null);
    castAndCrew.removeWhere((entry) => entry["profile_path"] == null);

    // Remove duplicates, leaving just the crew entry.
    // (Duplicates will happen when cast is also crew.)
    //
    // The justification for leaving the crew over the cast is that when a crew
    // member is also a cast member, it's usually because they are an important
    // crew member.
    // Crew job names can be shorter than character names which looks better.
    castAndCrew.removeWhere((entry) => castAndCrew.firstWhere((_e) => _e["name"] == entry["name"]) != entry);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SubtitleText(S.of(context).cast_and_crew),

          Container(
            height: 100,
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification){
                notification.disallowGlow();
                return false;
              },
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: castAndCrew.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Profile Image
                          Expanded(
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                      return CachedNetworkImage(
                                        height: constraints.maxHeight,
                                        width: constraints.maxHeight,
                                        placeholder: Image.memory(kTransparentImage),
                                        imageUrl: TMDB.IMAGE_CDN +
                                            castAndCrew[index]["profile_path"],
                                        fit: BoxFit.cover,
                                      );
                                    })
                                ),
                              )
                          ),

                          // Name
                          Text(castAndCrew[index]["name"], style: TextStyle(
                              fontFamily: 'GlacialIndifference',
                              fontSize: 16
                          )),

                          // Character or job
                          Text(
                            castAndCrew[index]["character"] != null ? castAndCrew[index]["character"] : castAndCrew[index]["job"],
                            style: TextStyle(
                                color: Colors.white54
                            ),
                          ),
                        ],
                      ),
                    );
                  }
              )
            )
          )
        ],
      ),
    );
  }

  ///
  /// generateLayout -
  /// This generates the remaining layout for the specific content type.
  /// It is a good idea to reference another class to keep this clean.
  ///
  Widget _generateLayout(ContentType contentType) {
    switch(contentType){
      case ContentType.TV_SHOW:
        // Generate TV show information
        return TVShowLayout.generate(context, _data);
      case ContentType.MOVIE:
        // Generate movie information
        return MovieLayout.generate(context, _data, _favIDs);
      default:
        return Container();
    }
  }

  ///
  /// getFloatingActionButton -
  /// This works like the generateLayout method above.
  /// This is used to add a floating action button to the layout.
  /// Just return null if your layout doesn't need a floating action button.
  ///
  Widget _getFloatingActionButton(ContentType contentType, BuildContext context, ContentModel model){
    switch(contentType){
      case ContentType.TV_SHOW:
        return null;
      case ContentType.MOVIE:
        return MovieLayout.getFloatingActionButton(context, model);
    }

    return null;
  }
}
