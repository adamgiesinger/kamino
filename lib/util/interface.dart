import 'package:flutter/material.dart';
import 'package:kamino/ui/uielements.dart';

class Interface {

  static void showAlert(BuildContext context, Widget title, List<Widget> content, bool dismissible, List<Widget> actions){
    showDialog<void>(
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

}