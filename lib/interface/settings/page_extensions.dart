import 'package:flutter/material.dart';
import 'package:kamino/api/realdebrid.dart';
import 'package:kamino/api/trakt.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/interface/settings/page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kamino/ui/interface.dart';

class ExtensionsSettingsPage extends SettingsPage {
  ExtensionsSettingsPage(BuildContext context) : super(
      title: S.of(context).extensions,
      pageState: ExtensionsSettingsPageState()
  );
}

class ExtensionsSettingsPageState extends SettingsPageState {

  bool traktAuthenticated = false;
  bool rdAuthenticated = false;

  @override
  void initState(){
    // Check if the services are authenticated.
    (() async {
      traktAuthenticated = await Trakt.isAuthenticated();
      rdAuthenticated = await RealDebrid.isAuthenticated();
      setState(() {});
    })();


    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {

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
                title: Text(S.of(context).trakttv),
                subtitle: Text(S.of(context).trakt_description),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).sync),
                      onPressed: (traktAuthenticated) ? () async {
                        //Interface.showLoadingDialog(context, title: S.of(context).syncing, canCancel: true);

                        Trakt.synchronize(context, silent: false);
                        //KaminoAppDelegateProxy state = context.ancestorStateOfType(const TypeMatcher<KaminoAppDelegateProxy>());
                        //Trakt.syncWatchHistory(state.context);

                        //Navigator.of(context).pop();
                      } : null,
                    ),
                    !traktAuthenticated ?
                      // Trakt account is not linked: show connect option
                      FlatButton(
                        textColor: Theme.of(context).primaryTextTheme.body1.color,
                        child: TitleText(S.of(context).connect),
                        onPressed: () async {
                          await Trakt.authenticate(context, shouldShowSnackbar: true);
                          this.traktAuthenticated = await Trakt.isAuthenticated();
                          Trakt.synchronize(context, silent: false);
                          setState(() {});
                        },
                      ) :
                    // Trakt account is linked: show disconnect option
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).disconnect),
                      onPressed: () async {
                        await Trakt.deauthenticate(context, shouldShowSnackbar: true);
                        this.traktAuthenticated = await Trakt.isAuthenticated();
                        setState(() {});
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
                title: Text(S.of(context).realdebrid),
                subtitle: Text(S.of(context).rd_description),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    !rdAuthenticated ? FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).connect),
                      onPressed: () async {
                        await RealDebrid.authenticate(context, shouldShowSnackbar: true);
                        this.rdAuthenticated = await RealDebrid.isAuthenticated();
                        setState(() {});
                      },
                    ) :
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).disconnect),
                      onPressed: () async {
                        await RealDebrid.deauthenticate(context, shouldShowSnackbar: true);
                        this.rdAuthenticated = await RealDebrid.isAuthenticated();
                        setState(() {});
                      },
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