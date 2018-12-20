import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class ThemeConfiguration {

  final bool allowsVariants;

  final String id;
  final String name;
  final String author;
  final String version;

  final SystemUiOverlayStyle overlayStyle;

  ThemeConfiguration(
    {
      @required this.id,
      @required this.allowsVariants,
      @required this.overlayStyle,

      @required this.name,
      @required this.author,
      @required this.version
    }
  );

  ThemeData getThemeData({Color primaryColor});

  SystemUiOverlayStyle getOverlayStyle(){
    return this.overlayStyle;
  }

  String getId(){
    return this.id;
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
    return this.allowsVariants;
  }

}

class ThemeConfigurationAdapter {

  final String id;
  final String name;
  final String author;
  final String version;
  final bool allowsVariants;
  final SystemUiOverlayStyle overlayStyle;

  static fromConfig(ThemeConfiguration config){
    return new ThemeConfigurationAdapter(
      id: config.id,
      name: config.name,
      author: config.author,
      version: config.version,
      allowsVariants: config.allowsVariants,
      overlayStyle: config.overlayStyle
    );
  }

  ThemeConfigurationAdapter({
    this.id,
    this.name,
    this.author,
    this.version,
    this.allowsVariants,
    this.overlayStyle
  });

  SystemUiOverlayStyle getOverlayStyle(){
    return this.overlayStyle;
  }

  String getId(){
    return this.id;
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
    return this.allowsVariants;
  }

}