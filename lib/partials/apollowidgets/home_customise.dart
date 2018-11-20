import 'package:flutter/material.dart';
import 'package:kamino/main.dart';
import 'package:kamino/partials/apollowidgets/_widget.dart';
import 'package:kamino/ui/uielements.dart';

class HomeCustomiseWidget extends ApolloWidget {

  @override
  List<Widget> construct() {
    return <Widget>[
      ListTile(
        leading: const Icon(Icons.lightbulb_outline),
        title: Padding(padding: EdgeInsets.only(top: 10), child: TitleText("Welcome to $appName")),
        subtitle: Text("This is your Launchpad!\nYou can choose what you want to see here..."),
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
    ];
  }

}