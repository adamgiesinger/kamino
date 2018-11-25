import 'package:flutter/material.dart';

class Interface {
  static void showAlert(BuildContext context, Widget title, List<Widget> content, bool dismissible, List<Widget> actions){
    Future<void> exec() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: dismissible,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: title,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: content,
            ),
            actions: actions

            /*<Widget>[
              FlatButton(
                child: Text('Dismiss'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ]*/
          );
        }
      );
    }

    exec();
  }
}