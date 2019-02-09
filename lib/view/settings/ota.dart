import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Map> checkUpdate(BuildContext context, bool dismissSnackbar) async {
  //get the build info
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String buildNumber = packageInfo.buildNumber;

  String url = "https://houston.apollotv.xyz/ota/download";

  //get latest build info from, houston
  Response res = await http.get("https://houston.apollotv.xyz/ota/");

  if (res.statusCode == 200) {
    var results = json.decode(res.body);

    if (buildNumber != results["latest"]["buildNumber"]) {
      //new version is available
      return {
        "title": results["latest"]["title"],
        "build": results["latest"]["buildNumber"],
        "url": url,
        "changelog": results["latest"]["changelog"]
      };
    }
  }

  return {"title": "", "build": "", "url": null, "changelog": ""};
}

updateApp(BuildContext context, bool dismissSnackbar) async {
  Map data = await checkUpdate(context, dismissSnackbar);
  print("update url is: ${data["url"]}");

  //show update dialog
  if (data["url"] != null) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return AlertDialog(
            title: TitleText(data["title"]),
            content: Text(
              data["changelog"],
              style: TextStyle(
                  fontSize: 18.0,
                  fontFamily: "GlacialIndifference",
                  color: Colors.white),
            ),
            actions: <Widget>[
              Center(
                child: FlatButton(
                  onPressed: () async {
                    if (await canLaunch(data["url"])) {
                      await launch(data["url"]);
                      Navigator.pop(context);
                    } else {
                      //throw 'Could not launch $url';
                      Scaffold.of(context).showSnackBar(new SnackBar(
                        content: Text(
                          "Unable to update, try again later",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "GlacialIndifference",
                              fontSize: 17.0),
                        ),
                        backgroundColor: Colors.red,
                        duration: new Duration(milliseconds: 600),
                      ));
                    }
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: "GlacialIndifference",
                        color: Colors.white),
                  ),
                ),
              ),
              Center(
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Dismiss",
                    style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: "GlacialIndifference",
                        color: Colors.white),
                  ),
                ),
              )
            ],
            //backgroundColor: Theme.of(context).cardColor,
          );
        });
  } else {
    if (dismissSnackbar == false) {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: Text(
          "You have the latest version",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "GlacialIndifference",
              fontSize: 17.0),
        ),
        backgroundColor: Colors.green,
        duration: new Duration(milliseconds: 600),
      ));
    }
  }
}
