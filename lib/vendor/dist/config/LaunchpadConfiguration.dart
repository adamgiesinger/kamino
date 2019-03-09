import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kamino/api/tmdb.dart';

import 'package:flutter/material.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/interface/launchpad/core_widgets/home_customise.dart';
import 'package:kamino/interface/launchpad/launchpad_item.dart';
import 'package:kamino/interface/launchpad/see_all_expanded_view.dart';
import 'package:kamino/interface/smart_search/search_results.dart';
import 'package:kamino/partials/content_poster.dart';
import 'package:kamino/interface/content/overview.dart';

class LaunchpadConfiguration {

  void initialize() {
    _registerLaunchpadItems();
  }

  ///
  /// You should edit this method to add/remove available launchpad items.
  ///
  void _registerLaunchpadItems() {
    LaunchpadItemManager.getManager().register(new LaunchpadItemWrapper(
      id: "xyz.apollotv.widgets.welcome_card",
      enabled: true,
      child: LaunchpadItem(
        title: "Welcome to ApolloTV",
        icon: Icon(Icons.lightbulb_outline),
        contents: HomeCustomiseWidget(),
        wrapContent: false,
      )
    ));

    LaunchpadItemManager.getManager().register(new LaunchpadItemWrapper(
        id: "xyz.apollotv.widgets.tmdb_popular_movies",
        enabled: true,
        child: LaunchpadItem(
          title: "Popular Movies",
          icon: Icon(Icons.star),
          contents: ListTmdbLaunchpadItem(
            endpoint: "popular",
            contentType: ContentType.MOVIE,
          ),
          action: ListTmdbLaunchpadItem.buildExpandedCardAction(ContentType.MOVIE, "popular")
        )
    ));

    LaunchpadItemManager.getManager().register(new LaunchpadItemWrapper(
        id: "xyz.apollotv.widgets.tmdb_top_rated_movies",
        child: LaunchpadItem(
          title: "Top Rated Movies",
          icon: Icon(Icons.arrow_upward),
          contents: ListTmdbLaunchpadItem(
            endpoint: "top_rated",
            contentType: ContentType.MOVIE,
          ),
          action: ListTmdbLaunchpadItem.buildExpandedCardAction(ContentType.MOVIE, "top_rated")
        )
    ));

    LaunchpadItemManager.getManager().register(new LaunchpadItemWrapper(
        id: "xyz.apollotv.widgets.tmdb_popular_tv_shows",
        child: LaunchpadItem(
          title: "Popular TV Shows",
          icon: Icon(Icons.star),
          contents: ListTmdbLaunchpadItem(
            endpoint: "popular",
            contentType: ContentType.TV_SHOW,
          ),
          action: ListTmdbLaunchpadItem.buildExpandedCardAction(ContentType.TV_SHOW, "popular"),
        )
    ));

    LaunchpadItemManager.getManager().register(new LaunchpadItemWrapper(
        id: "xyz.apollotv.widgets.tmdb_top_rated_tv_shows",
        enabled: true,
        child: LaunchpadItem(
          title: "Top Rated TV Shows",
          icon: Icon(Icons.arrow_upward),
          contents: ListTmdbLaunchpadItem(
            endpoint: "top_rated",
            contentType: ContentType.TV_SHOW,
          ),
          action: ListTmdbLaunchpadItem.buildExpandedCardAction(ContentType.TV_SHOW, "top_rated"),
        )
    ));
  }

}

class ListTmdbLaunchpadItem extends StatefulWidget {

  final ContentType contentType;
  final String endpoint;

  ListTmdbLaunchpadItem({
    @required this.contentType,
    @required this.endpoint,
  });

  @override
  createState() => ListTmdbLaunchpadItemState();

  static Widget buildExpandedCardAction(ContentType contentType, String endpoint){
    return Builder(
      builder: (BuildContext context){
        LaunchpadItem parentWidget = context.ancestorWidgetOfExactType(LaunchpadItem);

        return new MaterialButton(
          highlightColor: Theme.of(context).accentTextTheme.body1.color.withOpacity(0.3),
          minWidth: 0,
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
          child: Text("See All", style: TextStyle(color: Theme.of(context).primaryTextTheme.body1.color)),
          onPressed: (){
            Navigator.of(context).push(
              new MaterialPageRoute(builder: (context) => ExpandedCard(
                title: parentWidget.title,
                url: getBaseURL(contentType, endpoint),
                mediaType: contentType == ContentType.MOVIE ? "movie" : "tv",
              ))
            );
          }
        );
      }
    );
  }

  static String getBaseURL(ContentType contentType, String endpoint){
    var mediaType = contentType == ContentType.MOVIE ? "movie" : "tv";
    return "${TMDB.ROOT_URL}/$mediaType/$endpoint${TMDB.defaultArguments}";
  }

}

class ListTmdbLaunchpadItemState extends State<ListTmdbLaunchpadItem> {

  List<SearchModel> _data;
  String _baseUrl;

  @override
  void initState(){
    _baseUrl = "${ListTmdbLaunchpadItem.getBaseURL(widget.contentType, widget.endpoint)}&page=1";

    _getDiscoverData(_baseUrl).then((data){
      try {
        setState(() {
          _data = data;
        });
      }catch(ignored){}
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      height: 175,
      child: _posterListView(context),
    );
  }

  Widget _posterListView(BuildContext context){
    if(_data == null){
      return Container(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor
            ),
          ),
        ),
      );
    }

    if(_data.length == 0){
      return Container(
        child: Center(
          child: Text("An error occurred."),
        ),
      );
    }

    return Container(
      child: ListView.builder(
          shrinkWrap: false,
          scrollDirection: Axis.horizontal,
          itemCount: _data.length,
          itemBuilder: (BuildContext context, int index) {
            SearchModel item = _data[index];

            return InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContentOverview(
                      contentId: _data[index].id,
                      contentType: widget.contentType
                    )
                  )
                );
              },
              onLongPress: (){},
              child: Container(
                width: 120,
                child: new ContentPoster(
                  name: item.name,
                  background: item.poster_path,
                  mediaType: widget.contentType == ContentType.MOVIE ? "movie" : "tv",
                  releaseDate: item.year,
                  isFav: false
                ),
              ),
            );
        })
    );
  }

  Future<List<SearchModel>> _getDiscoverData(String _baseUrl) async {
    List<SearchModel> _discoverData = [];
    Map _temp;

    http.Response _res = await http.get(_baseUrl);
    _temp = jsonDecode(_res.body);

    if (_temp["results"] != null) {
      int total_pages = _temp["total_pages"];
      int resultsCount = _temp["results"].length;

      for(int x = 0; x < resultsCount; x++) {
        _discoverData.add(SearchModel.fromJSON(
            _temp["results"][x], total_pages));
      }
    }

    return _discoverData;
  }

}