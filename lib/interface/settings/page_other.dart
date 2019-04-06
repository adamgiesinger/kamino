import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/ui/interface.dart';
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

  bool _autoplaySourcesEnabled = false;

  @override
  void initState(){
    // This is done for legacy reasons.
    // We would upgrade the setting but we do intent to switch back
    // to having autoplay enabled by default.
    (Settings.manuallySelectSourcesEnabled as Future).then((data){
      setState(() {
        _autoplaySourcesEnabled = !data;
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
          child: SwitchListTile(
            isThreeLine: true,
            activeColor: Theme.of(context).primaryColor,
            value: _autoplaySourcesEnabled,
            title: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme.of(context).primaryColor,
                  ),
                  margin: EdgeInsetsDirectional.only(end: 5),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text("Experimental"),
                ),

                Flexible(child: TitleText(S.of(context).source_autoplay, allowOverflow: true))
              ]
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                S.of(context).source_autoplay_description,
                style: TextStyle(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            onChanged: (value) async {
              if (value != _autoplaySourcesEnabled){
                await (Settings.manuallySelectSourcesEnabled = !value); // ignore: await_only_futures
                (Settings.manuallySelectSourcesEnabled as Future).then((data) => setState(() => _autoplaySourcesEnabled = !data));
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
            onTap: () => Interface.showLanguageSelectionDialog(context),
          ),
        )

      ],
    );
  }

}
