import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/interface/smart_search/smart_search.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/elements.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class Interface {

  static Widget generateHeaderLogo(BuildContext context){
    KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());

    return Image.asset(
        appState.getActiveThemeData().brightness == Brightness.dark ?
        "assets/images/header_text.png" : "assets/images/header_text_dark.png",
        height: kToolbarHeight - 38
    );
  }

  static IconButton generateSearchIcon(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      color: Theme.of(context).primaryTextTheme.body1.color,
      onPressed: () => showSearch(context: context, delegate: SmartSearch()),
    );
  }

  static void showAlert({@required BuildContext context, @required Widget title, @required List<Widget> content, bool dismissible = false, @required List<Widget> actions}){
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (BuildContext responseContext) {
        return AlertDialog(
          title: title,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: content,
          ),
          actions: actions
        );
      }
    );
  }

  static Future<void> showSimpleErrorDialog(BuildContext context, {String title = "An error occurred", String reason = "Unable to determine reason..."}) async {
    Interface.showAlert(
        context: context,
        title: TitleText(title), // Title
        content: <Widget>[
          Text(reason)
        ],
        dismissible: true,
        actions: [
          new FlatButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Text("Close"),
            textColor: Theme.of(context).primaryColor,
          )
        ]
    );
  }

  static void showSnackbar(String text, { BuildContext context, ScaffoldState state, Color backgroundColor = Colors.green }){
    var snackbar = SnackBar(
      duration: Duration(milliseconds: 1500),
      content: TitleText(text),
      backgroundColor: backgroundColor,
    );

    if(context != null) { Scaffold.of(context).showSnackBar(snackbar); return; }
    if(state != null) { state.showSnackBar(snackbar); return; }

    print("Unable to show snackbar (text='$text')! No context or state was provided.");
  }

  static Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static showLanguageSelectionDialog(BuildContext context){
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

class EmptyScrollBehaviour extends ScrollBehavior {

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

}