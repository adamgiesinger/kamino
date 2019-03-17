import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/interface/launchpad/launchpad_item.dart';
import 'package:kamino/interface/smart_search/smart_search.dart';
import 'package:kamino/vendor/index.dart';

class LaunchpadItemRenderer extends StatefulWidget {

  final LaunchpadItemRendererState _state = LaunchpadItemRendererState();

  @override
  createState() => _state;

  Future<void> refresh() async {
    _state.refresh();
  }

}

class LaunchpadItemRendererState extends State<LaunchpadItemRenderer> {

  List<LaunchpadItemWrapper> _userOptions;

  @override
  void initState() {
    _getLaunchPrefs();
    super.initState();
  }

  Future<void> refresh() async {
    setState((){
      _userOptions = null;

      print("refreshed");

      _getLaunchPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_userOptions == null){
      return Container(child: Expanded(child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor
          ),
        ),
      )));
    }

    List<Widget> builderList = new List();

    _userOptions.forEach((userSelectedWidget){
      try {
        builderList.add(LaunchpadItemManager.getManager().getWidgetById(
            userSelectedWidget.id));
      } catch(_) {}
    });

    return Expanded(
      child: NotificationListener(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowGlow();
        },
        child: ListView.builder(
          itemCount: builderList.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index){
            return builderList[index];
          }
        )
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