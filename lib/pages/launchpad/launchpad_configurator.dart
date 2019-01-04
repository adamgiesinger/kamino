import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:dragable_flutter_list/dragable_flutter_list.dart';
import 'package:kamino/view/settings/settings_prefs.dart' as settingsPref;

class LaunchPadOptions extends StatefulWidget {

  @override
  _LaunchPadOptionsState createState() => new _LaunchPadOptionsState();
}

class _LaunchPadOptionsState extends State<LaunchPadOptions> {

  TextStyle _glacialFont = TextStyle(
      fontFamily: "GlacialIndifference");

  List<String> _userOptions = [];

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  void _getLaunchPrefs(){
    settingsPref.getListPref("launchpadOptions").then((data){
      setState(() {
        for(int x = 0; x < data.length; x++){
          _userOptions.add(data[x]);
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _getLaunchPrefs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("LaunchPad Config", style: _glacialFont,),
        backgroundColor: Theme.of(context).backgroundColor,
        centerTitle: false,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.help_outline),
              onPressed: ()=> showDialog(
                context: context, builder:(_)=> new SimpleDialog(
                title: Text("LaunchPad Configurator", style: _glacialFont,),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 18.0, right: 18.0),
                    child: Divider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text("Here you can swipe to dismiss cards you do "
                        "not want on your launchpad. You can also re-arrange"
                        " them to suit your needs.",
                      softWrap: true,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
                elevation: 8.0,
              ),)),
          IconButton(icon: Icon(Icons.autorenew),
            onPressed: (){
            setState(() {
              _userOptions = settingsPref.launchpadOptions();
              settingsPref.saveListPref("launchpadOptions", _userOptions);
            });

            //inform the user of the change
            _scaffoldKey.currentState.showSnackBar(
              new SnackBar(
                duration: Duration(milliseconds: 700),
                content: Text("Default values restored",
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
                backgroundColor: Colors.green,),
            );

            },
            tooltip: "Restore default",
          ),
        ],
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: _editableListView(),
    );
  }

  Widget _editableListView(){
    return Padding(
      padding: const EdgeInsets.only(top: 7.0),
      child: new DragAndDropList(
        _userOptions.length,
        itemBuilder: (BuildContext context, index) {
          return new SizedBox(
            child: Dismissible(
              background: Container(color: Colors.red.shade500,),
              key: new Key(_userOptions[index]),
              onDismissed: (direction){

                //update the shared preferences
                setState(() {
                  _userOptions.removeAt(index);
                  settingsPref.saveListPref("launchpadOptions", _userOptions);
                });

                //inform the user of the change
                _scaffoldKey.currentState.showSnackBar(
                  new SnackBar(
                    duration: Duration(milliseconds: 700),
                    content: Text("Item Dismissed",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                    ),
                    backgroundColor: Colors.red.shade500,),
                );
              },
              child: new Card(
                child: new ListTile(
                  leading: Icon(Icons.drag_handle),
                  title: new Text(_userOptions[index]),
                ),
              ),
            ),
          );
        },
        onDragFinish: (before, after) {
          print('on drag finish $before $after');

          String data = _userOptions[before];
          _userOptions.removeAt(before);
          setState(() {
            _userOptions.insert(after, data);
            settingsPref.saveListPref("launchpadOptions", _userOptions);
          });
        },
        canDrag: (index) {
          return true;
        },
        canBeDraggedTo: (one, two) => true,
        dragElevation: 15.0,
      ),
    );
  }

}
