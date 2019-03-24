import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/interface/settings/page.dart';

import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class AppearanceSettingsPage extends SettingsPage {

  AppearanceSettingsPage(BuildContext context, {bool isPartial = false}) : super(
    title: S.of(context).appearance,
    pageState: AppearenceSettingsPageState(),
    isPartial: isPartial
  );

}


class AppearenceSettingsPageState extends SettingsPageState {
  @override
  Widget buildPage(BuildContext context) {
    KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());

    return ListView(
      physics: widget.isPartial ? NeverScrollableScrollPhysics() : null,
      shrinkWrap: widget.isPartial ? true : false,
      children: <Widget>[
        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText(S.of(context).change_theme),
            subtitle: Text(
                "${appState.getActiveThemeMeta().getName()} (${S.of(context).by_x(appState.getActiveThemeMeta().getAuthor())})"
            ),
            onTap: () => showThemeChoice(context, appState),
          ),
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText(S.of(context).set_primary_color),
            subtitle: Text(
                PrimaryColorChooser.colorToHexString(Theme.of(context).primaryColor)
            ),
            trailing: CircleColor(
              circleSize: 32,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () => setPrimaryColor(context, appState),
          ),
        )
      ],
    );
  }
}

void setPrimaryColor(BuildContext context, KaminoAppState appState){
  showDialog(
      context: context,
      builder: (BuildContext dialog){
        return PrimaryColorChooser(
            initialColor: Theme.of(context).primaryColor
        );
      }
  );
}

void showThemeChoice(BuildContext context, KaminoAppState appState){
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialog){
        return AlertDialog(
          // Title Row
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.palette),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TitleText(S.of(context).change_theme),
                  )
                ],
              )
            ],
          ),

          // Body
          content: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: appState.getThemeConfigs().length,
                itemBuilder: (listContext, index){
                  var theme = appState.getThemeConfigs()[index];

                  return ListTile(
                      onTap: (){
                        Navigator.of(context).pop();
                        appState.setActiveTheme(theme.getId());
                      },
                      title: TitleText("${theme.getName()}"),
                      subtitle: Text("${theme.getAuthor()}")
                  );
                }
            ),
          ),
        );
      }
  );
}

/***** COLOR CHOOSER CODE *****/
class PrimaryColorChooser extends StatefulWidget {

  final Color initialColor;

  const PrimaryColorChooser({Key key, @required this.initialColor}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PrimaryColorChooserState(initialColor);

  static String colorToHexString(Color color){
    return "#${color.red.toRadixString(16)}" +
        color.green.toRadixString(16) +
        color.blue.toRadixString(16);
  }

}

class _PrimaryColorChooserState extends State<PrimaryColorChooser> {

  Color _activeColor;
  KaminoAppState appState;

  _PrimaryColorChooserState(Color initialColor){
    _activeColor = initialColor;
  }

  @override
  Widget build(BuildContext context) {
    appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleColor(
                circleSize: 32,
                color: _activeColor,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TitleText(S.of(context).set_primary_color),
              )
            ],
          )
        ],
      ),
      content: new Container(
        width: MediaQuery
            .of(context)
            .size
            .width * 0.75.clamp(0, 720),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MaterialColorPicker(
                onColorChange: (Color color) => setState(() => _activeColor = color),
                selectedColor: _activeColor,
                colors: _findMainColor(_activeColor) != null
                    ? materialColors : () {
                  // Return list of colors including the current primary color.
                  List<ColorSwatch<dynamic>> _anonymousColors = new List();
                  _anonymousColors.addAll(materialColors);
                  _anonymousColors.add(
                      ColorSwatch(_activeColor.value, <int, Color>{
                        500: _activeColor
                      }));
                  return _anonymousColors;
                }()
            ),

            new Container(
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new FlatButton(
                        onPressed: () {
                          KaminoAppState appState = context.ancestorStateOfType(
                              const TypeMatcher<KaminoAppState>());
                          appState.setPrimaryColorOverride(null);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          S.of(context).default_,
                          style: TextStyle(
                              color: appState
                                  .getActiveThemeData(ignoreOverride: true)
                                  .primaryColor
                          ),
                        )
                    ),

                    new RaisedButton(
                      color: _activeColor,
                      onPressed: (){
                        appState.setPrimaryColorOverride(_activeColor);
                        Navigator.of(context).pop();
                      },
                      child: Text(S.of(context).done)
                    )
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

  /* UTILS */
  ColorSwatch _findMainColor(Color shadeColor) {
    for (final mainColor in materialColors)
      if (_isShadeOfMain(mainColor, shadeColor)) return mainColor;

    return null;
  }

  bool _isShadeOfMain(ColorSwatch mainColor, Color shadeColor) {
    List<Color> shades = _getMaterialColorShades(mainColor);

    for (var shade in shades) if (shade == shadeColor) return true;

    return false;
  }

  List<Color> _getMaterialColorShades(ColorSwatch color) {
    List<Color> colors = [];
    if (color[50] != null) colors.add(color[50]);
    if (color[100] != null) colors.add(color[100]);
    if (color[200] != null) colors.add(color[200]);
    if (color[300] != null) colors.add(color[300]);
    if (color[400] != null) colors.add(color[400]);
    if (color[500] != null) colors.add(color[500]);
    if (color[600] != null) colors.add(color[600]);
    if (color[700] != null) colors.add(color[700]);
    if (color[800] != null) colors.add(color[800]);
    if (color[900] != null) colors.add(color[900]);

    return colors;
  }

}