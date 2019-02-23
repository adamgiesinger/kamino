import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/interface.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

class OTAHelper {
  static const platform = const MethodChannel('xyz.apollotv.kamino/ota');

  static Future<void> installOTA(String path) async {
    try {
      await platform.invokeMethod('install', <String, dynamic>{
        "path": path
      });
    } on PlatformException catch (e) {
      print("ERROR INSTALLING UPDATE: $e");
    }
  }
}

Future<Map> checkUpdate(BuildContext context, bool dismissSnackbar) async {
  //get the build info
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String buildNumber = packageInfo.buildNumber;

  String url = "https://houston.apollotv.xyz/ota/download";

  //get latest build info from, houston
  Response res = await http.get("https://houston.apollotv.xyz/ota/");

  if (res.statusCode == 200) {
    var results = json.decode(res.body);

    if (int.parse(results["latest"]["buildNumber"]) > int.parse(buildNumber)) {
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

///
/// Consider [dismissSnackbar] to be ignoreSnackbar.
///
updateApp(BuildContext context, bool dismissSnackbar) async {
  if(!Platform.isAndroid) return;

  bool permissionStatus = await SimplePermissions.checkPermission(Permission.WriteExternalStorage);
  if(!permissionStatus) permissionStatus = (await SimplePermissions.requestPermission(Permission.WriteExternalStorage)) == PermissionStatus.authorized;
  if(!permissionStatus && dismissSnackbar) return;

  if(permissionStatus) {
    final downloadDir = new Directory(
        (await getExternalStorageDirectory()).path + "/.apollo");
    if (!await downloadDir.exists()) await downloadDir.create();
    final downloadFile = new File("${downloadDir.path}/update.apk");
    if (await downloadFile.exists()) await downloadFile.delete();
  }

  Map data = await checkUpdate(context, dismissSnackbar);

  //show update dialog
  if (data["url"] != null) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: TitleText(data["title"]),
            content: Text(
              data["changelog"],
              style: TextStyle(
                  color: Colors.white
              ),
            ),
            actions: <Widget>[
              Center(
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: TitleText("Dismiss", textColor: Colors.white)
                ),
              ),
              Center(
                child: FlatButton(
                  onPressed: () => runInstallProcedure(context, data),
                  child: TitleText("Install", textColor: Colors.white)
                ),
              )
            ],
            //backgroundColor: Theme.of(context).cardColor,
          );
        });
  } else {
    if (dismissSnackbar == false) {
      Interface.showSnackbar('You have the latest version.', context: context);
    }
  }
}

runInstallProcedure (context, data) async {
  try {
    Navigator.of(context).pop();

    bool permissionStatus = await SimplePermissions.checkPermission(Permission.WriteExternalStorage);
    if(!permissionStatus) permissionStatus = (await SimplePermissions.requestPermission(Permission.WriteExternalStorage)) == PermissionStatus.authorized;
    if(!permissionStatus) throw new FileSystemException("Permission denied.");

    final downloadDir = new Directory((await getExternalStorageDirectory()).path + "/.apollo");
    if(!await downloadDir.exists()) await downloadDir.create();
    final downloadFile = new File("${downloadDir.path}/update.apk");
    if(await downloadFile.exists()) await downloadFile.delete();

    showLoadingDialog(context, "Updating...", Text("Downloading update file..."));
    http.Client client = new http.Client();
    var req = await client.get(data["url"]);
    var bytes = req.bodyBytes;
    await downloadFile.writeAsBytes(bytes);

    Navigator.of(context).pop();
    OTAHelper.installOTA(downloadFile.path);
  }catch(e){
    String message = "Update failed. Please try again later.";

    if(e is FileSystemException) message = "Update failed. Storage permission denied.";

    if(Scaffold.of(context, nullOk: true) != null) {
      Interface.showSnackbar(message, context: context, backgroundColor: Colors.red);
      return;
    }else{
      showDialog(
          context: context,
          builder: (_){
            return AlertDialog(
              title: TitleText("Error updating app..."),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: TitleText("Dismiss", textColor: Colors.white)
                )
              ],
            );
          }
      );
    }
  }
}

void showLoadingDialog(BuildContext context, String title, Widget content){
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_){
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: TitleText(title),
            content: SingleChildScrollView(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 20),
                      child: new CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor
                        ),
                      )
                  ),
                  Center(child: content)
                ],
              ),
            ),
          )
        );
      }
  );
}