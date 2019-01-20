import 'package:flutter/material.dart';
import 'package:kamino/ui/uielements.dart';

class SettingsPage extends StatefulWidget {

  final String title;
  final SettingsPageState pageState;

  SettingsPage({
    @required this.title,
    @required this.pageState
  });

  @override
  createState() => pageState;

}

abstract class SettingsPageState extends State<SettingsPage> {

  GlobalKey<ScaffoldState> _scaffoldKey;

  ///
  /// A [Widget] containing all of the settings widgets.
  ///
  Widget buildPage(BuildContext context);

  List<Widget> actions(BuildContext context){
    // Returns a blank list unless overridden.
    return <Widget>[];
  }

  GlobalKey<ScaffoldState> getScaffoldKey(){
    return _scaffoldKey;
  }

  @override
  void initState() {
    _scaffoldKey = new GlobalKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: TitleText(widget.title),
        backgroundColor: Theme.of(context).backgroundColor,

        // Center title
        centerTitle: true,

        // Page actions
        actions: actions(context),
      ),
      body: new Builder(builder: (BuildContext context) {
        return new Container(
          color: Theme.of(context).backgroundColor,
          child: buildPage(context),
        );
      })
    );
  }

}