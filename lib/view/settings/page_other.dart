import 'package:flutter/material.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/view/settings/page.dart';

import 'package:kamino/view/settings/settings_prefs.dart' as settingsPref;

class OtherSettingsPage extends SettingsPage {

  OtherSettingsPage() : super(
      title: "Other",
      pageState: OtherSettingsPageState()
  );

}


class OtherSettingsPageState extends SettingsPageState {

  bool _expandedSearchValue = false;

  @override
  void initState(){
    settingsPref.getBoolPref("expandedSearch").then((data){
      setState(() {
        //print("initial expanded search value is $data");
        _expandedSearchValue = data;
      });
    });

    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return ListView(
      children: <Widget>[
        Material(
          color: Theme.of(context).backgroundColor,
          child: CheckboxListTile(
            isThreeLine: true,
            activeColor: Theme.of(context).primaryColor,
            value: _expandedSearchValue,
            title: TitleText("Detailed Content Information"),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Replaces the grid of posters with a list of more detailed cards on search and overview pages.",
                style: TextStyle(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            onChanged: (value){
              if (value != _expandedSearchValue){
                settingsPref.saveBoolPref("expandedSearch", value).then((data){
                  setState(() {
                    _expandedSearchValue = data;
                  });
                });
              }
            },
          ),
        )
      ],
    );
  }

}
