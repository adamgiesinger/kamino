import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/view/settings/page.dart';
import 'package:device_info/device_info.dart';


class AdvancedSettingsPage extends SettingsPage {

  AdvancedSettingsPage({bool isPartial = false}) : super(
      title: "Advanced",
      pageState: AdvancedSettingsPageState(),
      isPartial: isPartial
  );

}

class AdvancedSettingsPageState extends SettingsPageState {

  @override
  Widget buildPage(BuildContext context) {
    return ListView(
      physics: widget.isPartial ? NeverScrollableScrollPhysics() : null,
      shrinkWrap: widget.isPartial ? true : false,
      children: <Widget>[
        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText("Change Default Server"),
            subtitle: Text("Manually override the default content server."),
            enabled: true,
            onTap: (){

            },
          ),
        ),

        Divider(),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText("Run Connectivity Test"),
            subtitle: Text("Checks whether sources can be reached."),
            enabled: true,
            onTap: () => {},
          ),
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText("Get Device Information"),
            subtitle: Text("Gathers useful information for debugging."),
            enabled: true,
            onTap: () async {
              var deviceInfoPlugin = DeviceInfoPlugin();

              if(Platform.isAndroid){
                AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;

                String info = "";
                info += ("${deviceInfo.manufacturer} ${deviceInfo.model} (${deviceInfo.product})") + "\n";
                info += ("\n");
                info += ("Hardware: ${deviceInfo.hardware} (Bootloader: ${deviceInfo.bootloader})") + "\n";
                info += ("\t\t--> Supports: ${deviceInfo.supportedAbis.join(',')}") + "\n";
                info += ("\t\t--> IPD: ${deviceInfo.isPhysicalDevice}") + "\n";
                info += ("\n");
                info += ("Software: Android ${deviceInfo.version.release}, SDK ${deviceInfo.version.sdkInt} (${deviceInfo.version.codename})") + "\n";
                info += ("\t\t--> Build ${deviceInfo.display} (${deviceInfo.tags})");

                var response = await http.post("https://hastebin.com/documents", body: info);
                String key = jsonDecode(response.body)["key"];

                await Clipboard.setData(new ClipboardData(text: "https://hastebin.com/$key.apollodebug"));
                Interface.showSnackbar('Link copied to clipboard.', context: context);

                return;
              }

              /*if(Platform.isIOS){
                print(await deviceInfo.iosInfo);
                return;
              }*/
            },
          ),
        ),
      ],
    );
  }

}
