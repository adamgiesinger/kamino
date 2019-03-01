import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/util/trakt.dart';
import 'package:kamino/interface/settings/page.dart';

import 'package:kamino/interface/settings/settings_prefs.dart' as settingsPref;
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherSettingsPage extends SettingsPage {

  OtherSettingsPage({bool isPartial = false}) : super(
      title: "Other",
      pageState: OtherSettingsPageState(),
      isPartial: isPartial
  );

}

class OtherSettingsPageState extends SettingsPageState {

  bool _sourceSelection = false;
  bool _expandedSearchValue = false;

  @override
  void initState(){
    settingsPref.getBoolPref("expandedSearch").then((data){
      setState(() {
        _expandedSearchValue = data;
      });
    });

    settingsPref.getBoolPref("sourceSelection").then((data){
      setState(() {
        _sourceSelection = data;
      });
    });

    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return ListView(
      physics: widget.isPartial ? NeverScrollableScrollPhysics() : null,
      shrinkWrap: widget.isPartial ? true : false,
      children: <Widget>[
        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: CheckboxListTile(
            isThreeLine: true,
            activeColor: Theme.of(context).primaryColor,
            value: _sourceSelection,
            title: TitleText("Manually Select Sources"),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Shows a dialog with a list of discovered sources instead of automatically choosing one.",
                style: TextStyle(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            onChanged: (value){
              if (value != _sourceSelection){
                settingsPref.saveBoolPref("sourceSelection", value).then((data){
                  setState(() {
                    _sourceSelection = data;
                  });
                });
              }
            },
          ),
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
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
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText("Clear Search History"),
            subtitle: Text("Removes search suggestions based on past searches."),
            enabled: true,
            onTap: (){
              settingsPref.saveListPref("searchHistory", []);
              Interface.showSnackbar("Search history cleared.", context: context);
            },
          ),
        )

      ],
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}
