import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/main.dart';

class TitleText extends Text {

  TitleText(String text, {double fontSize : 18, Color textColor, bool allowOverflow = false, TextAlign textAlign}) : super(
    text,
    overflow: (allowOverflow ? null : TextOverflow.ellipsis),
    style: TextStyle(
      fontFamily: 'GlacialIndifference',
      fontSize: fontSize,
      color: textColor,
    ),
    textAlign: textAlign,
    maxLines: (allowOverflow ? null : 1)
  );

}

class SubtitleText extends StatelessWidget {

  final String text;
  final EdgeInsetsGeometry padding;

  SubtitleText(this.text, {
    Key key,
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 10)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Text(text.toUpperCase(), style: TextStyle(
        fontSize: 14,
        fontFamily: 'GlacialIndifference',
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
        color: Theme.of(context).primaryTextTheme.display3.color,
      ), textAlign: TextAlign.start),
      padding: padding,
    );
  }

}

class ConcealableText extends StatefulWidget {

  final String text;
  final String revealLabel;
  final String concealLabel;
  final Color color;
  final Color revealLabelColor;

  final int maxLines;

  ConcealableText(this.text, {
    @required this.revealLabel,
    @required this.concealLabel,
    @required this.maxLines,
    this.color,
    this.revealLabelColor
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
            text: widget.text,
            style: Theme.of(context).primaryTextTheme.body1.copyWith(
              color: widget.color
            )
          );

          var textPainter = TextPainter(
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
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
                        fontWeight: FontWeight.bold,
                        color: widget.revealLabelColor
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

class VerticalIconButton extends StatelessWidget {

  Color backgroundColor;
  Color foregroundColor;
  Widget icon;
  Widget title;
  EdgeInsetsGeometry padding;
  BorderRadiusGeometry borderRadius;
  GestureTapCallback onTap;


  VerticalIconButton({
    @required this.icon,
    @required this.title,
    @required this.onTap,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    this.borderRadius
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(5),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: borderRadius ?? BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          padding: padding,
          child: Column(
            children: <Widget>[
              icon,
              Container(child: title, margin: EdgeInsets.only(top: 10))
            ]
          )
        )
      )
    );
  }

}

class OfflineMixin extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.offline_bolt, size: 48, color: Colors.grey),
            Container(padding: EdgeInsets.symmetric(vertical: 10)),
            TitleText(S.of(context).youre_offline, fontSize: 24),
            Container(padding: EdgeInsets.symmetric(vertical: 3)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                S.of(context).appname_failed_to_connect_to_the_internet(appName),
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}