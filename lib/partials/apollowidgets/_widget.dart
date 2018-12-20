import 'package:flutter/material.dart';

abstract class ApolloWidget extends StatelessWidget {

  ApolloWidget();

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: new Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        elevation: 5.0,
        color: Theme.of(context).cardColor,
        child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: construct(context)
        ),
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
  List<Widget> construct(BuildContext context);

}