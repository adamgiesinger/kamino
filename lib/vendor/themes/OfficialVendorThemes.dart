import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino/vendor/struct/ThemeConfiguration.dart';

class OfficialVendorTheme {

  static final _DarkVendorTheme dark = _DarkVendorTheme();
  static final _LightVendorTheme light = _LightVendorTheme();
  static final _BlackVendorTheme black = _BlackVendorTheme();

}

class _DarkVendorTheme extends ThemeConfiguration {

  static const _primaryColor = const Color(0xFF8147FF);

  _DarkVendorTheme(): super(
    id: "xyz.apollotv.dark",
    name: "ApolloTV Official",
    author: "Apollo15",
    allowsVariants: true,
    overlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light
    )
  );

  @override
  ThemeData getThemeData({Color primaryColor : _primaryColor}) {
    var _highlightColor = primaryColor.withOpacity(0.1490);

    var _backgroundColor = Color(0xFF26282C);
    var _cardColor = Color(0xFF2F3136);

    return ThemeData(
        brightness: Brightness.dark,
        primaryColorBrightness: Brightness.dark,
        primaryColor: primaryColor,
        accentColor: primaryColor,
        highlightColor: _highlightColor,
        backgroundColor: _backgroundColor,
        cursorColor: primaryColor,
        textSelectionHandleColor: primaryColor,
        buttonColor: primaryColor,
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
          ),
        ),
        dialogBackgroundColor: _cardColor,
        buttonTheme: ButtonThemeData(
            buttonColor: primaryColor
        ),
        cardColor: _cardColor,
        bottomAppBarColor: _backgroundColor,
        scaffoldBackgroundColor: _cardColor,
        canvasColor: _backgroundColor
    );
  }

}

class _LightVendorTheme extends ThemeConfiguration {

  static const _primaryColor = const Color(0xFFA279FB);

  _LightVendorTheme(): super(
    id: "xyz.apollotv.light",
    name: "ApolloTV Official (Light)",
    author: "Apollo15",
    allowsVariants: true,
    overlayStyle: SystemUiOverlayStyle.light.copyWith(
      statusBarBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark
    )
  );

  @override
  ThemeData getThemeData({Color primaryColor : _primaryColor}) {
    var _highlightColor = primaryColor.withOpacity(0.1490);

    var _backgroundColor = Color(0xFFECF0F1);
    var _cardColor = Color(0xFFeff3f4);

    return ThemeData(
      brightness: Brightness.light,
      primaryColorBrightness: Brightness.light,
      accentColorBrightness: Brightness.dark,
      primaryColor: primaryColor,
      accentColor: primaryColor,
      highlightColor: _highlightColor,
      backgroundColor: _backgroundColor,
      cursorColor: primaryColor,
      textSelectionHandleColor: primaryColor,
      buttonColor: primaryColor,
      dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
          )
      ),
      buttonTheme: ButtonThemeData(
          buttonColor: primaryColor,
          textTheme: ButtonTextTheme.primary
      ),
      dialogBackgroundColor: _backgroundColor,
      cardColor: _cardColor,
      bottomAppBarColor: _backgroundColor,
      scaffoldBackgroundColor: _cardColor,
      canvasColor: _backgroundColor
    );
  }

}

class _BlackVendorTheme extends ThemeConfiguration {

  static const _primaryColor = const Color(0xFF8147FF);

  _BlackVendorTheme(): super(
    id: "xyz.apollotv.black",
    name: "ApolloTV Official (AMOLED)",
    author: "Apollo15",
    allowsVariants: true,
    overlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light
    ),
  );

  @override
  ThemeData getThemeData({Color primaryColor : _primaryColor}) {
    var _highlightColor = primaryColor.withOpacity(0.1490);

    var _backgroundColor = Color(0xFF000000);
    var _cardColor = _backgroundColor;

    return ThemeData(
      brightness: Brightness.dark,
      primaryColorBrightness: Brightness.dark,
      primaryColor: primaryColor,
      accentColor: primaryColor,
      highlightColor: _highlightColor,
      backgroundColor: _backgroundColor,
      cursorColor: primaryColor,
      textSelectionHandleColor: primaryColor,
      buttonColor: primaryColor,
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
        ),
      ),
      dialogBackgroundColor: _cardColor,
      buttonTheme: ButtonThemeData(
          buttonColor: primaryColor
      ),
      cardColor: _cardColor,
      bottomAppBarColor: _backgroundColor,
      scaffoldBackgroundColor: _cardColor,
      canvasColor: _backgroundColor
    );
  }

}
