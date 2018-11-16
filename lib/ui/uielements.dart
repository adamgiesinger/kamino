
import 'package:flutter/material.dart';

class TitleText extends Text {

  TitleText(String data, {double fontSize, Color textColor, bool allowOverflow = false, TextAlign textAlign}) : super(
    data,
    overflow: (allowOverflow ? null : TextOverflow.ellipsis),
    style: TextStyle(
      fontFamily: 'GlacialIndifference',
      fontSize: fontSize,
      color: textColor
    ),
    textAlign: textAlign,
    maxLines: (allowOverflow ? null : 1)
  );

}