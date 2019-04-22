import 'package:flutter/material.dart';
import 'package:kamino/api/trakt.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/util/settings.dart';
import 'package:kamino/util/trakt.dart' as trakt;
import 'package:kamino/interface/settings/page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExtensionsSettingsPage extends SettingsPage {
  ExtensionsSettingsPage(BuildContext context) : super(
      title: S.of(context).extensions,
      pageState: ExtensionsSettingsPageState()
  );
}

class ExtensionsSettingsPageState extends SettingsPageState {

  TraktSettings traktSettings;

  @override
  void initState(){
    Settings.traktCredentials.then((data) => setState((){
      traktSettings = data;
    }));

    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    bool traktConnected = traktSettings != null && traktSettings.isValid();

    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      children: <Widget>[

        Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          elevation: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                isThreeLine: true,
                leading: SvgPicture.asset("assets/icons/trakt.svg", height: 36, width: 36, color: const Color(0xFFED1C24)),
                title: Text('Trakt.tv'),
                subtitle: Text(S.of(context).trakt_description),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).sync),
                      onPressed: (traktConnected) ? (){
                        Trakt.synchronize(context, silent: false);
                      } : null,
                    ),
                    !traktConnected ?
                      // Trakt account is not linked: show connect option
                      FlatButton(
                        textColor: Theme.of(context).primaryTextTheme.body1.color,
                        child: TitleText(S.of(context).connect),
                        onPressed: () async {
                          await Trakt.authenticate(context, shouldShowSnackbar: true);
                          this.traktSettings = await Trakt.getTraktSettings();
                          setState(() {});
                        },
                      ) :
                    // Trakt account is linked: show disconnect option
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).disconnect),
                      onPressed: () async {
                        await Trakt.deauthenticate(context, shouldShowSnackbar: true);
                        setState(() {
                          traktSettings = TraktSettings.unauthenticated();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          elevation: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                isThreeLine: true,
                leading: SvgPicture.asset("assets/icons/realdebrid.svg", height: 36, width: 36, color: const Color(0xFF78BB6F)),
                title: Text('Real-Debrid'),
                subtitle: Text(S.of(context).rd_description),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).coming_soon),
                      onPressed: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

}