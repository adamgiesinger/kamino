import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:kamino/api/realdebrid.dart';
import 'package:kamino/api/trakt.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/interface/settings/page.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

        SubtitleText(S.of(context).content_trackers),

        Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          elevation: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10),
                child: ListTile(
                  isThreeLine: true,
                  leading: SvgPicture.asset("assets/icons/trakt.svg", height: 36, width: 36, color: const Color(0xFFED1C24)),
                  title: Text("Trakt.tv", style: TextStyle(fontFamily: 'GlacialIndifference', fontSize: 18)),
                  subtitle: Container(
                      height: 30,
                      child: AutoSizeText(S.of(context).trakt_description, overflow: TextOverflow.visible)
                  ),
                ),
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
                          traktAuthenticated = await Trakt.isAuthenticated();

                          if(traktAuthenticated) Trakt.synchronize(context, silent: false);
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
              Container(
                padding: EdgeInsets.only(top: 10),
                child: ListTile(
                  isThreeLine: true,
                  leading: SvgPicture.asset("assets/icons/simkl.svg", height: 36, width: 36, color: const Color(0xFFFFFFFF)),
                  title: Text("SIMKL", style: TextStyle(fontFamily: 'GlacialIndifference', fontSize: 18)),
                  subtitle: Container(
                      height: 30,
                      child: AutoSizeText(S.of(context).simkl_description, overflow: TextOverflow.visible)
                  ),
                ),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).coming_soon)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SubtitleText(S.of(context).premium_hosts),

        Card(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          elevation: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10),
                child: ListTile(
                  isThreeLine: true,
                  leading: SvgPicture.asset("assets/icons/realdebrid.svg", height: 36, width: 36, color: const Color(0xFF78BB6F)),
                  title: Text("Real-Debrid", style: TextStyle(fontFamily: 'GlacialIndifference', fontSize: 18)),
                  subtitle: Container(
                      height: 30,
                      child: AutoSizeText(S.of(context).rd_description, overflow: TextOverflow.visible)
                  ),
                ),
              ),
              ButtonTheme.bar( // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    !rdAuthenticated ? FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).connect),
                      onPressed: () async {
                        await RealDebrid.authenticate(context, shouldShowSnackbar: true);
                        rdAuthenticated = await RealDebrid.isAuthenticated();
                        setState(() {});
                      },
                    ) :
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).disconnect),
                      onPressed: () async {
                        await RealDebrid.deauthenticate(context, shouldShowSnackbar: true);
                        rdAuthenticated = await RealDebrid.isAuthenticated();
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