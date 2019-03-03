import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/interface/settings/page.dart';

import 'package:kamino/interface/settings/settings_prefs.dart' as settingsPref;
import 'package:url_launcher/url_launcher.dart';

class OtherSettingsPage extends SettingsPage {

  OtherSettingsPage(BuildContext context, {bool isPartial = false}) : super(
      title: S.of(context).other_,
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
            title: TitleText(S.of(context).manually_select_sources),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                S.of(context).manually_select_sources_description,
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
            title: TitleText(S.of(context).detailed_content_information),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                S.of(context).detailed_content_information_description,
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
            title: TitleText(S.of(context).clear_search_history),
            subtitle: Text(S.of(context).clear_search_history_description),
            enabled: true,
            onTap: (){
              settingsPref.saveListPref("searchHistory", []);
              Interface.showSnackbar(S.of(context).search_history_cleared, context: context);
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
