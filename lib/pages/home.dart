import 'package:flutter/material.dart';
import 'package:kamino/main.dart';
import 'package:kamino/pages/_page.dart';
import 'package:kamino/ui/uielements.dart';

class HomePage extends Page {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: EdgeInsets.only(top: 5.0),
        color: backgroundColor,
        child: new ListView(children: [
          new Card(
            elevation: 5.0,
            color: const Color(0xFF2F3136),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: TitleText("Welcome to $appName"),
                  subtitle: const Text("Let's get started by customising your homepage!"),
                ),

                ButtonTheme.bar(
                  textTheme: ButtonTextTheme.primary,
                  layoutBehavior: ButtonBarLayoutBehavior.constrained,
                  child: ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: TitleText(
                          "Customise...",
                          fontSize: 16,
                        ),
                        onPressed: (){},
                      )
                    ],
                  ),
                )
              ]
            ),

          ),

          new Card(
              elevation: 3.0,
              color: const Color(0xFF2F3136),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: TitleText('Trending on ApolloTV'),
                    subtitle: const Text('What others are watching.'),
                  )
                ],
              )
          )
        ]));
  }
}
