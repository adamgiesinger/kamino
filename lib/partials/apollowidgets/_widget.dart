import 'package:flutter/material.dart';

abstract class ApolloWidget extends StatelessWidget {

  ApolloWidget();

  @override
  Widget build(BuildContext context) {
    return new Card(
      elevation: 5.0,
      color: const Color(0xFF2F3136),
      child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: construct()
      ),
    );
  }

  ///
  /// Use this to create the contents of the widget card.
  /// This allows us to make changes to widgets as a whole, without
  /// manually changing each widget.
  ///
  /// This means you should, if at all possible, avoid using [build].
  ///
  List<Widget> construct();

}