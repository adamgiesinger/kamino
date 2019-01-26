import 'package:flutter/material.dart';
import 'package:kamino/pages/launchpad/launchpad_renderer.dart';
import 'dart:async';
import 'package:kamino/util/trakt.dart' as trakt;
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;

class LaunchpadController extends StatefulWidget {
  @override
  LaunchpadControllerState createState() => new LaunchpadControllerState();
}

class LaunchpadControllerState extends State<LaunchpadController> {

  LaunchpadItemRenderer _renderer;

  @override
  void initState() {

    //check if trakt token needs renewing
    trakt.renewToken(context);

    _renderer = new LaunchpadItemRenderer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _renderer.refresh();
        await new Future.delayed(new Duration(seconds: 1));
        return null;
      },
      color: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).backgroundColor,
      child: Scrollbar(child: Container(
        color: Theme.of(context).backgroundColor,
          child: Column(children: <Widget>[
            _renderer
          ]),
      )),
    );
  }

}
