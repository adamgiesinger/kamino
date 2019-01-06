import 'package:flutter/material.dart';
import 'package:kamino/main.dart';
import 'package:kamino/models/content.dart';
import 'package:kamino/models/movie.dart';
import 'package:kamino/partials/poster.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/util/ui_constants.dart';
import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/view/content/overview.dart';

class MovieLayout{

  static Widget generate(BuildContext context, MovieContentModel _data, List<int> _favsArray){
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Column(
            children: <Widget>[
              /* Similar Movies */
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                      title: TitleText(
                          'Similar Movies',
                          fontSize: 22.0,
                          textColor: Theme.of(context).primaryColor
                      )
                  ),

                  SizedBox(
                    height: 200.0,
                    child: _generateSimilarMovieCards(_data, _favsArray)
                  )
                ],
              )
              /* ./Similar Movies */


            ]
      ),
        )
    );
  }

  ///
  /// applyTransformations() -
  /// Allows this layout to apply transformations to the overview scaffold.
  /// This should be used to add a play FAB, for example.
  ///
  static Widget getFloatingActionButton(BuildContext context, MovieContentModel model){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: new Row(
            children: <Widget>[
              Expanded(
                  child: new FloatingActionButton.extended(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    ),
                    onPressed: (){
                      Interface.showAlert(
                          context,
                          new TitleText('Searching for Sources...'),
                          [
                            Center(
                              child: Text("BETA NOTE: If you find yourself waiting more than 30 seconds, there's a good chance we're experiencing server issues."),
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                    child: new CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                    )
                                )
                            )
                          ],
                          false,
                          [Container()]
                      );

                      KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());
                      appState.getVendorConfigs()[0].playMovie(
                          model.title,
                          context
                      );
                    },
                    icon: Container(),
                    label: Text(
                      "Play Movie",
                      style: TextStyle(
                        letterSpacing: 0.0,
                        fontFamily: 'GlacialIndifference',
                        fontSize: 18.0
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 30
                  )
              )
            ]
        )
    );
  }

  /* PRIVATE SUBCLASS-SPECIFIC METHODS */

  static Widget _generateSimilarMovieCards(MovieContentModel _data, List<int> _favsArray){

    return _data.recommendations == null ? Container() : ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: _data.recommendations.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: index == 0
              ? const EdgeInsets.only(left: 18.0)
              : const EdgeInsets.only(left: 5.0),
          child: InkWell(
            onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ContentOverview(
                          contentId: _data.recommendations[index]["id"],
                          contentType: ContentType.MOVIE
                        ),
                    )
                );
            },
            onLongPress: (){
              saveFavPopUpDialog(
                  context, _data.recommendations[index]["title"], _data.recommendations[index]["id"],
                  tmdb.image_cdn + _data.recommendations[index]["posterPath"],
                  _data.recommendations[index]["releaseDate"], "movie");
            },
            splashColor: Colors.white,
            child: SizedBox(
              width: 152,
              child:  Poster(
                name: _data.recommendations[index]["title"],
                background: _data.recommendations[index]["poster_path"],
                mediaType: 'movie',
                releaseDate: _data.recommendations[index]["release_date"],
                isFav: _favsArray.contains(_data.recommendations[index]["id"]),
              ),
            ),
          ),
        );
    });
  }

}