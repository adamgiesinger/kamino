import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/ui/ui_utils.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/interface/settings/page.dart';

import 'package:kamino/util/settings.dart';

class OtherSettingsPage extends SettingsPage {

  OtherSettingsPage(BuildContext context, {bool isPartial = false}) : super(
      title: S.of(context).other_,
      pageState: OtherSettingsPageState(),
      isPartial: isPartial
  );

}

class OtherSettingsPageState extends SettingsPageState {

  bool _manuallySelectSourcesEnabled = false;
  bool _detailedContentInfoEnabled = false;

  @override
  void initState(){
    (Settings.detailedContentInfoEnabled as Future).then((data){
      setState(() {
        _detailedContentInfoEnabled = data;
      });
    });

    (Settings.manuallySelectSourcesEnabled as Future).then((data){
      setState(() {
        _manuallySelectSourcesEnabled = data;
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
            value: _manuallySelectSourcesEnabled,
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
            onChanged: (value) async {
              if (value != _manuallySelectSourcesEnabled){
                await (Settings.manuallySelectSourcesEnabled = value); // ignore: await_only_futures
                (Settings.manuallySelectSourcesEnabled as Future).then((data) => setState(() => _manuallySelectSourcesEnabled = data));
              }
            },
          ),
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: CheckboxListTile(
            isThreeLine: true,
            activeColor: Theme.of(context).primaryColor,
            value: _detailedContentInfoEnabled,
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
            onChanged: (value) async {
              if (value != _detailedContentInfoEnabled){
                await (Settings.detailedContentInfoEnabled = value); // ignore: await_only_futures
                (Settings.detailedContentInfoEnabled as Future).then((data) => setState(() => _detailedContentInfoEnabled = data));
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
            onTap: () async {
              await (Settings.searchHistory = <String>[]);
              Interface.showSnackbar(S.of(context).search_history_cleared, context: context);
            },
          ),
        ),

        Divider(),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText(S.of(context).language_settings),
            subtitle: Text(S.of(context).$_language_name),
            enabled: true,
            onTap: () => showLanguageSelectionDialog(context),
          ),
        )

      ],
    );
  }

}
