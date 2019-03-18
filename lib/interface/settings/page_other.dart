import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/interface/settings/page.dart';

import 'package:kamino/util/settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:transparent_image/transparent_image.dart';

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
            onTap: _showLanguageSelectionDialog,
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

  _showLanguageSelectionDialog(){
    showDialog(
        context: context,
        builder: (_) {
          var localesList = S.delegate.supportedLocales.map((element) => element).toList();
          localesList.sort((a, b) => a.languageCode.compareTo(b.languageCode) * -1);
          localesList.sort((_l1, _l2) => _l1.languageCode == "en" ? -1 : 1);
          localesList.sort((_l1, _l2) => _l1.languageCode == "en"
              && _l1.countryCode == "GB"
              && _l2.languageCode == "en"
              && _l2.countryCode == "" ? 1 : -1);

          return SimpleDialog(
            title: TitleText(S.of(context).select_language),
            children: <Widget>[
              Container(
                height: 400,
                width: 300,
                child: ListView.builder(itemBuilder: (BuildContext context, int index) {
                  var currentLocale = localesList[index];
                  var iconFile = currentLocale.languageCode;
                  var iconVariant = currentLocale.countryCode;

                  // Flag corrections
                  if(iconFile == "ar") iconFile = "_assets/flags/arab_league.png";
                  if(iconFile == "he") iconFile = "_assets/flags/hebrew.png";
                  if(iconFile == "en" && iconVariant == "GB") iconFile = "gb";
                  if(iconFile == "en") iconFile = "us";
                  // ./Flag corrections

                  Future<S> _loadLocaleData = S.delegate.load(currentLocale);

                  return FutureBuilder(future: _loadLocaleData, builder: (_, AsyncSnapshot<S> snapshot) {
                    return ListTile(
                      title: TitleText(snapshot.data.$_language_name),
                      subtitle: Text(snapshot.data.$_language_name_english),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(48),
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 400),
                          placeholder: MemoryImage(kTransparentImage),
                          image: AssetImage(
                            !iconFile.startsWith("_") ?
                              'icons/flags/png/$iconFile.png'
                                : iconFile.replaceFirst("_", ""),
                            package: iconFile.startsWith("_") ? null : 'country_icons',
                          ),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: 48,
                          height: 48,
                        )
                      ),
                      enabled: true,
                      onTap: () async {
                        KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());
                        await appState.setLocale(currentLocale);
                        Navigator.of(context).pop();
                      },
                    );
                  });
                }, itemCount: localesList.length, shrinkWrap: true)
            )
          ]);
        }
    );
  }

}
