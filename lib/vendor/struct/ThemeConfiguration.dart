import 'dart:core';
import 'package:flutter/material.dart';

abstract class ThemeConfiguration {

  final ThemeData themeData;
  final bool allowVariants;

  final String name;
  final String author;
  final String version;

  ThemeConfiguration(
    {
      @required this.themeData,
      @required this.allowVariants,

      @required this.name,
      @required this.author,
      @required this.version
    }
  );

  ThemeData getThemeData(){
    return this.themeData;
  }

  String getName(){
    return this.name;
  }

  String getAuthor(){
    return this.author;
  }

  String getVersion(){
    return this.version;
  }

  bool doesAllowVariants(){
    return this.allowVariants;
  }

}