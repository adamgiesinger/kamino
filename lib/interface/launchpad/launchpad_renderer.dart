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

      LaunchpadItemManager.getManager().reset();
      ApolloVendor.getLaunchpadConfiguration().initialize();

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

    builderList.add(_searchButton());

    _userOptions.forEach((userSelectedWidget){
      builderList.add(LaunchpadItemManager.getManager().getWidgetById(userSelectedWidget.id));
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
    LaunchpadItemManager.getManager().getLaunchpadConfiguration(onlyEnabled: true).then((activeItems){
      setState(() {
        _userOptions = activeItems;
      });
    });
  }

  Widget _searchButton() {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
        child: new Material(
          elevation: 5,
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(100),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              showSearch(context: context, delegate: SmartSearch());
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15, left: 20),
                  child: new Text(
                    S.of(context).search_tv_shows_and_movies,
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'GlacialIndifference',
                        color: Colors.grey),
                  ),
                ),
                new Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: new Icon(
                      Icons.search,
                      color: Colors.grey,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

}