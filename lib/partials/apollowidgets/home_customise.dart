import 'package:flutter/material.dart';
import 'package:kamino/main.dart';
import 'package:kamino/partials/apollowidgets/_widget.dart';
import 'package:kamino/ui/uielements.dart';

class HomeCustomiseWidget extends ApolloWidget {

  @override
  List<Widget> construct(BuildContext context) {
    return <Widget>[
      ListTile(
        leading: const Icon(Icons.lightbulb_outline),
        title: Padding(padding: EdgeInsets.only(top: 10), child: TitleText("Welcome to $appName")),
        subtitle: Padding(padding: EdgeInsets.only(top: 10), child: Text("This is your Launchpad!\nYou can choose what you want to see here...")),
      ),

      ButtonTheme.bar(
        textTheme: ButtonTextTheme.primary,
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
        child: ButtonBar(
          children: <Widget>[
            FlatButton(
              textColor: Theme.of(context).primaryTextTheme.body1.color,
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