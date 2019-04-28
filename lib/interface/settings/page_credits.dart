import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/interface/settings/page.dart';
import 'package:kamino/ui/elements.dart';
import 'package:transparent_image/transparent_image.dart';

class CreditsSettingsPage extends SettingsPage {

  CreditsSettingsPage(BuildContext context) : super(
      title: S.of(context).credits,
      pageState: CreditsSettingsPageState()
  );
  
}

class CreditsSettingsPageState extends SettingsPageState {

  Map<String, dynamic> _contributors;

  Future<Null> _fetchContributors() async {
    String content = await rootBundle.loadString("assets/contributors.json");
    Map<String, dynamic> contributors = jsonDecode(content);

    setState(() {
      _contributors = contributors;
    });
  }

  @override
  void initState() {
    _fetchContributors();
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    if(_contributors == null){
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      itemCount: _contributors.length + 1,
      itemBuilder: (BuildContext context, int index){
        if(index == 0){
          return Card(
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15).copyWith(bottom: 30),
            child: Container(
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  Image.asset("assets/images/logo.png", height: 48),
                  Container(margin: EdgeInsets.symmetric(vertical: 5)),
                  TitleText("Thank you!", fontSize: 22),
                  Container(margin: EdgeInsets.symmetric(vertical: 5)),
                  Text(
                    "ApolloTV is a community effort and without these people, this app wouldn't exist. For everyone's contribution, no matter how small, I am extremely grateful.\n\n~NBTX",
                    style: TextStyle(
                      color: Colors.grey[400]
                    )
                  )
                ],
              ),
            ),
          );
        }
        index--;

        String role = _contributors.keys.toList()[index];
        List roleMembers = _contributors[role];

        return Column(
          children: <Widget>[
            SubtitleText(role),
            ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10).copyWith(bottom: 20),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: roleMembers.length,
              itemBuilder: (BuildContext context, int index){
                String image = roleMembers[index]['image'].replaceAll('size=2048', 'size=64');
                String name = roleMembers[index]['name'];
                Color color = Color(int.parse(roleMembers[index]['color'].substring(1, 7), radix: 16) + 0xFF000000);

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: ClipRRect(
                      clipBehavior: Clip.antiAlias,
                      borderRadius: BorderRadius.circular(100),
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: image,
                        width: 48,
                        height: 48,
                      ),
                    ),
                    title: TitleText(name, textColor: color),
                  ),
                );
              }
            )
          ],
        );
      },
    );
  }

}