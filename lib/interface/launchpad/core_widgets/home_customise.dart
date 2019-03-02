import 'package:flutter/material.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/interface/settings/page_launchpad.dart';

class HomeCustomiseWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
        ),
        elevation: 5.0,
        color: Theme.of(context).cardColor,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => LaunchpadSettingsPage(context)
                      ));
                    },
                  )
                ],
              ),
            )
          ]
        ),
      ),
    );
  }

}