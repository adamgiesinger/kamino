
import 'package:flutter/material.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/pages/search/bloc.dart';
import 'package:kamino/pages/search/provider.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:kamino/partials/poster.dart';
import 'package:kamino/view/content/overview.dart';

import 'search/model.dart';

class SearchPage extends StatefulWidget {
  @override
  SearchPageState createState() => new SearchPageState();
}


class SearchPageState extends State<SearchPage> {

  List<int> _favIDs = [];

  @override
  void initState() {
    super.initState();
  }

  final resultBloc = SearchResultBloc(API());
  final TextEditingController _searchControl = TextEditingController();

  _openContentScreen(BuildContext context, AsyncSnapshot snapshot, int index) {
    //print("id is ${snapshot.data[index].showID}");

    if (snapshot.data[index].mediaType == "tv") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ContentOverview(
                      contentId: snapshot.data[index].showID,
                      contentType: ContentType.TV_SHOW )
          )
      );
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ContentOverview(
                      contentId: snapshot.data[index].showID,
                      contentType: ContentType.MOVIE )
          )
      );
    }
  }

  Widget _tvStream(BuildContext context, var resultBloc) {
    return StreamBuilder(
      stream: resultBloc.results,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Empty on first load
          //TODO: Add progress spinner after search term entered.
          return Container();

        } else if (snapshot.hasError) {
          return Center(child: CircularProgressIndicator());

        } else if (snapshot.data == null) {
          return Center(child: Text("Nothing to see here..."));

        } else {
          if (snapshot.data.length > 0) {

            //refresh the favs db
            databaseHelper.getAllFavIDs().then((data){
              _favIDs = data;
            });

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.76,
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () => _openContentScreen(context, snapshot, index),
                  splashColor: Colors.white,
                  child: Poster(
                    background: snapshot.data[index].posterPath,
                    name: snapshot.data[index].title,
                    releaseDate: snapshot.data[index].year,
                    mediaType: snapshot.data[index].mediaType,
                    isFav: _favIDs.contains(snapshot.data[index].id),
                  ),
                );
              },
            );
          } else {
            return Center(
                child: Text(
                  "We've got nothing...",
                  style: TextStyle(
                      fontSize: 26.0,
                      fontFamily: 'GlacialIndifference',
                      color: Theme.of(context).primaryTextTheme.body1.color),
                ));
          }
        }
      },
    );
  }

  @override
  void dispose() {
    resultBloc.dispose();
    _searchControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchResultProvider(
      resultBloc: SearchResultBloc(API()),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Container(
          margin: EdgeInsets.only(top: 40),
          child: Column(
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: new Stack(
                  alignment: Alignment(1.0, 0.0),
                  children: <Widget>[
                    new Container(
                      margin: const EdgeInsets.only(top: 10.0),
                      child: new PhysicalModel(
                          borderRadius: BorderRadius.circular(25),
                          elevation: 15.0,
                          color: Theme.of(context).cardColor,
                          child: new Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 15.0),
                              child: Container(
                                  margin: EdgeInsets.only(left: 5, right: 45),
                                  child: new TextField(
                                    autofocus: true,
                                    controller: _searchControl,
                                    autocorrect: true,
                                    cursorColor: Theme.of(context).primaryColor,
                                    style: TextStyle(
                                        fontFamily: 'GlacialIndifference',
                                        fontSize: 18.0,
                                        color: Theme.of(context).primaryTextTheme.body1.color),
                                    decoration: new InputDecoration.collapsed(
                                        hintText: "Search TV shows and movies...",
                                        hintStyle: TextStyle(color: Colors.grey)
                                    ),
                                    keyboardAppearance: Brightness.dark,
                                    onEditingComplete: () {
                                      resultBloc.query.add(_searchControl.text);
                                      FocusScope.of(context).requestFocus(new FocusNode());
                                    },
                                    textInputAction: TextInputAction.search,
                                    textCapitalization: TextCapitalization.words
                                  )
                              )
                          )
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Material(
                        color: const Color(0x00000000),
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)
                          ),
                          splashColor: const Color(0x10FFFFFF),
                          onTap: (){
                            resultBloc.query.add(_searchControl.text);
                            FocusScope.of(context).requestFocus(new FocusNode());
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Icon(Icons.search,
                                      size: 28.0, color: Colors.grey
                                  )
                                ],
                              )
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  child: Center(
                    child: StreamBuilder(
                      stream: resultBloc.log,
                      builder: (context, snapshot) => Container(
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(snapshot.data ?? '',
                              style: TextStyle(
                                  color: Theme.of(context).primaryTextTheme.body1.color,
                                  fontFamily: 'GlacialIndifference',
                                  fontSize: 15.0
                              ),
                              textAlign: TextAlign.center
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(child: _tvStream(context, resultBloc))
            ],
          ),
        ),
      ),
    );
  }

}
