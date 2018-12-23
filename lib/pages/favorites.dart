import 'package:flutter/material.dart';
import 'package:kamino/ui/uielements.dart';

class FavoritesPage extends StatefulWidget {
  @override
  FavoritesPageState createState() => new FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.all(10),
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[new Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          elevation: 5.0,
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.priority_high),
                  title: Padding(padding: EdgeInsets.only(bottom: 5), child: TitleText("Coming Soon!")),
                  subtitle: const Text("We're still working on this!\nPlease check back later."),
                )
              ]
            ),
          ),
        )]
      )
    );
  }

}