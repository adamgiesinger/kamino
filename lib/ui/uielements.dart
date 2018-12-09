
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

class ConcealableText extends StatefulWidget {

  final String text;
  final String revealLabel;
  final String concealLabel;

  final int maxLines;

  ConcealableText(this.text, {
    @required this.revealLabel,
    @required this.concealLabel,
    @required this.maxLines
  });

  @override
  State<StatefulWidget> createState() => ConcealableTextState();
}

class ConcealableTextState extends State<ConcealableText> {

  bool isConcealed = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LayoutBuilder(builder: (context, size){
          var textSpan = TextSpan(
            text: widget.text
          );

          var textPainter = TextPainter(
            maxLines: widget.maxLines,
            textAlign: TextAlign.start,
            textDirection: Directionality.of(context),
            text: textSpan
          );

          textPainter.layout(maxWidth: size.maxWidth);
          var exceeded = textPainter.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                textSpan,
                overflow: TextOverflow.fade,
                maxLines: (isConcealed ? widget.maxLines : null)
              ),

              (exceeded ?
                GestureDetector(
                  onTap: (){
                    setState((){
                      isConcealed = !isConcealed;
                    });
                  },
                  child: Padding(
                    padding: isConcealed ? EdgeInsets.only(top: 5.0) : EdgeInsets.only(top: 10.0),
                    child: Text(
                      isConcealed ? widget.revealLabel : widget.concealLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    )
                  ),
                )
                : Container()
              )
            ]
          );
        })
      ],
    );
  }

}