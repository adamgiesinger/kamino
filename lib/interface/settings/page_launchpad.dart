
import 'package:dragable_flutter_list/dragable_flutter_list.dart';
import 'package:flutter/material.dart';
import 'package:kamino/interface/launchpad/launchpad_item.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/interface/settings/page.dart';

class LaunchpadSettingsPage extends SettingsPage {

  LaunchpadSettingsPage() : super(
    title: "Launchpad",
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
      child: new DragAndDropList(
        _userOptions.length,
        itemBuilder: (BuildContext context, index) {
          LaunchpadItemWrapper item = _userOptions[index];

          return new SizedBox(
            child: new Card(
              child: new ListTile(
                leading: Icon(Icons.drag_handle),
                title: new Text(item.child.title),
                trailing: Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  value: item.enabled,
                  onChanged: (newValue){
                    // Update the shared preferences
                    setState(() {
                      item.enabled = !item.enabled;
                      LaunchpadItemManager.getManager().saveLaunchpadConfiguration(_userOptions);
                    });
                  }
                )
              ),
            )
          );
        },
        onDragFinish: (before, after) {
          var entry = _userOptions[before];
          _userOptions.removeAt(before);
          _userOptions.insert(after, entry);

          setState((){
            LaunchpadItemManager.getManager().saveLaunchpadConfiguration(_userOptions);
          });
        },
        canDrag: (index) => true,
        canBeDraggedTo: (one, two) => true,
        dragElevation: 15.0,
      ),
    );
  }

  @override
  List<Widget> actions(BuildContext context){
    return <Widget>[
      IconButton(icon: Icon(Icons.settings_backup_restore),
        onPressed: (){

          setState((){
            LaunchpadItemManager.getManager().clearLaunchpadConfiguration();
          });
          _getLaunchPrefs();

          //inform the user of the change
          Interface.showSnackbar("The default configuration has been restored.",
            state: getScaffoldKey().currentState
          );
          /*getScaffoldKey().currentState.showSnackBar(
            new SnackBar(
              duration: Duration(milliseconds: 1500),
              content: Text("The default configuration has been restored.",
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
              backgroundColor: Colors.green
            ),
          );*/

        },
        tooltip: "Restore Defaults",
      )
    ];
  }

  void _getLaunchPrefs(){
    LaunchpadItemManager.getManager().getLaunchpadConfiguration().then((activeItems){
      setState(() {
        _userOptions = activeItems;
      });
    });
  }

}