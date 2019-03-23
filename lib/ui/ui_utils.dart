import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/interface/smart_search/smart_search.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/util/databaseHelper.dart' as databaseHelper;
import 'package:kamino/api/tmdb.dart';
import 'package:kamino/util/trakt.dart' as trakt;
import 'package:transparent_image/transparent_image.dart';

Widget generateHeaderLogo(BuildContext context){
  KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());

  return Image.asset(
      appState.getActiveThemeData().brightness == Brightness.dark ?
      "assets/images/header_text.png" : "assets/images/header_text_dark.png",
      height: kToolbarHeight - 38
  );
}

IconButton generateSearchIcon(BuildContext context) {
  return IconButton(
    icon: Icon(Icons.search),
    color: Theme.of(context).primaryTextTheme.body1.color,
    onPressed: () => showSearch(context: context, delegate: SmartSearch()),
  );
}

void addFavoritePrompt(
    BuildContext context, String title,
    int id, String url, String year, String mediaType) async{

  //strip tmdb image cdn from input url
  url = url.replaceAll(TMDB.IMAGE_CDN, "");

  print("the title: $title \n id: $id \n url: $url \n year: $year \n mediaType: $mediaType");

  List<int> _favIDs = await databaseHelper.getAllFavIDs();

  if (!_favIDs.contains(id)){

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new TitleText("Add to Favorites"),
          content: new Text("Do you want to add $title to your favorites ?"),
          actions: <Widget>[

            // buttons to close the dialog or proceed with the save
            new FlatButton(
              child: new Text("Cancel",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            new FlatButton(
              child: new Text("Add",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0
                ),
              ),
              onPressed: () {

                //save the content to the database
                databaseHelper.saveFavorites(title, mediaType, id, url, year);

                trakt.sendNewMedia(context, mediaType, title, year, id);
                Navigator.pop(context);

              },
            ),
          ],
        );
      },
    );

  } else {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new TitleText("Remove from favorites"),
          content: new Text("Do you want to remove $title from your favorites ?"),
          actions: <Widget>[

            // buttons to close the dialog or proceed with the save
            new FlatButton(
              child: new Text("Cancel",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            new FlatButton(
              child: new Text("Remove",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0
                ),
              ),
              onPressed: () {

                //save the content to the database
                databaseHelper.removeFavorite(id);

                trakt.removeMedia(context, mediaType, id);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

showLanguageSelectionDialog(BuildContext context){
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