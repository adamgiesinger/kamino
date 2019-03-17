import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/util/settings.dart';

class LaunchpadItemManager {

  static LaunchpadItemManager _manager;
  Map<String, LaunchpadItemWrapper> _registeredItems;

  LaunchpadItemManager(){
    _registeredItems = new Map();
  }

  static LaunchpadItemManager getManager(){
    if(_manager == null) _manager = LaunchpadItemManager();
    return _manager;
  }

  void reset(){
    _registeredItems.clear();
  }

  LaunchpadItemManager register(LaunchpadItemWrapper item){
    String id = item.id;

    if(_registeredItems.containsKey(id)) throw new Exception("A widget with id '$id' has already been registered.");
    _registeredItems[id] = item;

    return this;
  }

  LaunchpadItemWrapper getItemById(String id){
    if(!_registeredItems.containsKey(id)) return null; // throw new Exception("Attempted to get invalid widget by id '$id'");
    return _registeredItems[id];
  }

  Widget getWidgetById(String id){
    return getItemById(id).child;
  }

  Map<String, LaunchpadItemWrapper> _getAllRegisteredItems(){
    return _registeredItems;
  }

  Future<List<LaunchpadItemWrapper>> getLaunchpadConfiguration() async {
    // Load userItemsTemp from SharedPreferences.
    String launchpadItems = await Settings.launchpadItems;
    LinkedHashMap<String, bool> userItemsTemp;
    userItemsTemp = launchpadItems != null ? new LinkedHashMap<String, bool>.from(jsonDecode(launchpadItems)) : new LinkedHashMap();

    // Now convert these SharedPreferences items into the wrapper list.
    List<LaunchpadItemWrapper> userItemsResult = new List();
    userItemsTemp.forEach((id, enabled){
      var item = getItemById(id);
      if(item != null) {
        item.enabled = enabled;
        userItemsResult.add(item);
      }
    });

    // Add any wrapper items that don't exist in the list to the end.
    this._getAllRegisteredItems().forEach((id, _wrapper) {
      // If the item ID is not in userItemsResult, add it.
      if (userItemsResult
          .where((result) => result.id == id)
          .length == 0) userItemsResult.add(_wrapper);
    });

    // Finally clone the List and if onlyEnabled is set to true, filter out ones that aren't enabled.
    List<LaunchpadItemWrapper> userItems = new List.from(userItemsResult);
    userItems.removeWhere((element) => !element.enabled);

    return userItems;
  }

  Future<void> saveLaunchpadConfiguration(List<LaunchpadItemWrapper> userOptions) async {
    LinkedHashMap<String, bool> launchpadItems = new LinkedHashMap();

    userOptions.forEach((wrapper){
      launchpadItems[wrapper.id] = wrapper.enabled;
    });

    await (Settings.launchpadItems = jsonEncode(launchpadItems));
  }

  Future<void> clearLaunchpadConfiguration() async {
    await (Settings.launchpadItems = null);
  }

}

class LaunchpadItemWrapper {

  final String id;
  final LaunchpadItem child;
  bool enabled;

  LaunchpadItemWrapper({
    this.id,
    this.child,
    this.enabled = false
  });

}

class LaunchpadItem extends StatefulWidget {

  final String title;
  final Icon icon;
  final Widget contents;
  final Widget action;
  final bool wrapContent;

  LaunchpadItem({
    @required this.title,
    @required this.icon,
    @required this.contents,
    this.action,
    this.wrapContent = true
  });

  @override
  createState() => LaunchpadItemState();

}

class LaunchpadItemState extends State<LaunchpadItem> {

  @override
  build(BuildContext context){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: (widget.wrapContent != null && !widget.wrapContent) ? widget.contents :
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          elevation: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  leading: widget.icon,
                  title: TitleText(widget.title),
                  trailing: widget.action != null ? widget.action : Icon(null)
              ),

              /* Widget content */
              Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5, left: 5),
                child: widget.contents,
              )
            ],
          ),
        ),
    );
  }

}