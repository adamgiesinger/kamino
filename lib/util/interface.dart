import 'package:flutter/material.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:url_launcher/url_launcher.dart';

class Interface {

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

}

class EmptyScrollBehaviour extends ScrollBehavior {

  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }

}