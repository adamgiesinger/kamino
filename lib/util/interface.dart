import 'package:flutter/material.dart';

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
}