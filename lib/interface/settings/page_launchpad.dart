import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/interface/launchpad/launchpad_item.dart';
import 'package:kamino/interface/settings/page.dart';

class LaunchpadSettingsPage extends SettingsPage {

  LaunchpadSettingsPage(BuildContext context) : super(
    title: S.of(context).launchpad,
    pageState: LaunchpadSettingsPageState(),
  );

}

class LaunchpadSettingsPageState extends SettingsPageState {

  List<LaunchpadItemWrapper> _userOptions;

  @override
  void initState(){
    _getLaunchPrefs();
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context){
    if(_userOptions == null){
      return Container(
        child: Center(
          child: new CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation(
                  Theme.of(context).primaryColor
              )
          )
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Center(
        child: Text("Sam, please replace placeholder text"),
      ),
    );
  }

  void _getLaunchPrefs(){
    LaunchpadItemManager.getManager().getLaunchpadConfiguration().then((activeItems){
      setState(() {
        _userOptions = activeItems;
      });
    });
  }

}