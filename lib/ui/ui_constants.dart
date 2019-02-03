import 'package:flutter/material.dart';
import 'package:kamino/pages/smart_search/smart_search.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:kamino/api/tmdb.dart' as tmdb;
import 'package:kamino/util/trakt.dart' as trakt;


IconButton searchIconButton(BuildContext context) {

  return IconButton(
    icon: Icon(Icons.search),
    color: Colors.white,
    onPressed: () => showSearch(context: context, delegate: SmartSearch()),
  );
}

void addFavoritePrompt(
    BuildContext context, String title,
    int id, String url, String year, String mediaType) async{

  //strip tmdb image cdn from input url
  url = url.replaceAll(tmdb.image_cdn, "");

  print("the title: $title \n id: $id \n url: $url \n year: $year \n mediaType: $mediaType");

  List<int> _favIDs = await databaseHelper.getAllFavIDs();

  if (!_favIDs.contains(id)){

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new TitleText("Add to Favorites"),
          content: new Text("Do you want to add $title to your favorites ?"),
          actions: <Widget>[

            // buttons to close the dialog or proceed with the save
            new FlatButton(
              child: new Text("Cancel",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            new FlatButton(
              child: new Text("Add",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0
                ),
              ),
              onPressed: () {

                //save the content to the database
                databaseHelper.saveFavourites(title, mediaType, id, url, year);

                trakt.sendNewMedia(context, mediaType, title, year, id);
                Navigator.pop(context);

              },
            ),
          ],
        );
      },
    );

  } else {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new TitleText("Remove from favorites"),
          content: new Text("Do you want to remove $title from your favorites ?"),
          actions: <Widget>[

            // buttons to close the dialog or proceed with the save
            new FlatButton(
              child: new Text("Cancel",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            new FlatButton(
              child: new Text("Remove",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0
                ),
              ),
              onPressed: () {

                //save the content to the database
                databaseHelper.removeFavourite(id);

                trakt.removeMedia(context, mediaType, id);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }


}