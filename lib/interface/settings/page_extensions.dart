import 'package:flutter/material.dart';
import 'package:kamino/api/trakt.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/util/settings.dart';
import 'package:kamino/util/rd.dart' as rd;
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
  List<String> _rdCred;

  @override
  void initState(){
    Settings.traktCredentials.then((data) => setState((){
      traktSettings = data;
    }));

    ((Settings.rdCredentials) as Future).then((data) => setState((){
      _rdCred = data;
    }));


    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    bool traktConnected = traktSettings != null && traktSettings.isValid();
    bool rdConnected = _rdCred != null && _rdCred.length == 3;

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
                    !rdConnected ? FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).connect),
                        onPressed: () async {
                        _signinToRD();
                        },
                    ) :
                    FlatButton(
                      textColor: Theme.of(context).primaryTextTheme.body1.color,
                      child: TitleText(S.of(context).disconnect),
                      onPressed: () async {
                        _clearRDCredentials();
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

// MOVE THIS TO rd.dart?
  void _signinToRD() async{

    Map data = await rd.getOAuthInfo();

    if (data["user_code"] != null){

      //open registration webview

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => new rd.RealDebrid(oauth_data: data),
        ),);

      print("rd response $result");

      //saving the token info, for future use

      if (result["access_token"] != null ){

        /*
        * IMPORTANT RD INFO - DO NOT DELETE
        * 0 - Access Code
        * 1 - Refresh Token
        * 2 - Expires in
        * */

        List<String> _cred = [result["access_token"],
        result["refresh_token"],
        DateTime.now().add(new Duration(seconds: result["expires_in"])).toString()];

        setState(() {
          _rdCred = _cred;
          Settings.rdCredentials = _rdCred;
        });
      }


    } else {

      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_){
            return AlertDialog(
              title: TitleText("Real Debrid authentication failed!"),
              content: Text("Unable to connect to Real Debrid. Try again later.",
                style: TextStyle(
                    color: Colors.white
                ),
              ),
              actions: <Widget>[
                Center(
                  child: FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: TitleText("Okay", textColor: Colors.white)
                  ),
                )
              ],
              //backgroundColor: Theme.of(context).cardColor,
            );
          }
      );

    }
  }

  void _clearRDCredentials() {

    //Ask user for confirmation
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_){
          return AlertDialog(
            title: TitleText("Disconnect from Real-Debrid"),
            content: Text("Are you sure ?",
              style: TextStyle(
                  color: Colors.white
              ),
            ),
            actions: <Widget>[
              Center(
                  child: FlatButton(
                    child: TitleText("Yes", textColor: Colors.white),
                    onPressed: (){

                      //clear rd credentials
                      setState(() {
                        _rdCred = [];
                        Settings.rdCredentials = _rdCred;
                      });

                      Navigator.pop(context);
                    },
                  )
              )
            ],
            //backgroundColor: Theme.of(context).cardColor,
          );
        }
    );
  }

}