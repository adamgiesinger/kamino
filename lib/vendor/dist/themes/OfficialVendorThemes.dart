import 'package:flutter/material.dart';
import 'package:kamino/vendor/struct/ThemeConfiguration.dart';

class OfficialVendorTheme {

  static final _DarkVendorTheme dark = _DarkVendorTheme();

}

class _DarkVendorTheme extends ThemeConfiguration {

  static const _primaryColor = const Color(0xFF8147FF);
  static const _secondaryColor = const Color(0x168147FF);
  static const _backgroundColor = const Color(0xFF26282C);
  static const _cardColor = const Color(0xFF2F3136);
  static const _highlightColor = const Color(0x268147FF);

  _DarkVendorTheme(): super(
    name: "ApolloTV Official",
    version: "1.0.0",
    author: "Apollo15",
    allowVariants: true,

    themeData: ThemeData(
      brightness: Brightness.dark,
      primaryColor: _primaryColor,
      accentColor: _secondaryColor,
      splashColor: _backgroundColor,
      highlightColor: _highlightColor,
      backgroundColor: _backgroundColor,
      cursorColor: _primaryColor,
      textSelectionHandleColor: _primaryColor,
      buttonColor: _primaryColor,
      dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
          )
      ),
      buttonTheme: ButtonThemeData(
          buttonColor: _primaryColor
      ),
      cardColor: _cardColor,
      bottomAppBarColor: _backgroundColor,
      scaffoldBackgroundColor: _cardColor
    )
  );

}