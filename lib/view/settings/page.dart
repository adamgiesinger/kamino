import 'package:flutter/material.dart';
import 'package:kamino/ui/uielements.dart';

abstract class SettingsPage extends StatelessWidget {

  final String title;

  SettingsPage({
    @required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitleText(title),
        backgroundColor: Theme.of(context).backgroundColor,

        // Center title
        centerTitle: true,
      ),
      body: new Builder(builder: (BuildContext context) {
        return new Container(
          color: Theme.of(context).backgroundColor,
          child: pageContent(context),
        );
      })

    );
  }

  ///
  /// A [Widget] containing all of the settings widgets.
  ///
  Widget pageContent(BuildContext context);

}