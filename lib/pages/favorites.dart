import 'package:flutter/material.dart';
import 'package:kamino/pages/_page.dart';
import 'package:kamino/ui/uielements.dart';

class FavoritesPage extends Page {
  @override
  FavoritesPageState createState() => new FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {

  @override
  Widget build(BuildContext context) {
    return Container(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[new Card(
            elevation: 5.0,
            color: const Color(0xFF2F3136),
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