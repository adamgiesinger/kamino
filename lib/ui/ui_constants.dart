import 'package:flutter/material.dart';
import 'package:kamino/pages/smart_search/smart_search.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;


IconButton searchIconButton(BuildContext context) {

  return IconButton(
    icon: Icon(Icons.search),
    color: Colors.white,
    onPressed: () => showSearch(context: context, delegate: SmartSearch()),
  );
}

void addFavoritePrompt(
    BuildContext context, String title,
    int id, String url, String year, String mediaType){

  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new TitleText("Add to Favourites"),
        content: new Text("Do you want to add $title to your favourites ?"),
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
            child: new Text("Accept",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0
              ),
            ),
            onPressed: () {

              //save the content to the database
              databaseHelper.saveFavourites(
                  title, mediaType, id, url, year);

              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );

}