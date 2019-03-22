import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/ui/ui_elements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/interface/settings/page.dart';
import 'package:device_info/device_info.dart';
import 'package:kamino/util/settings.dart';


class AdvancedSettingsPage extends SettingsPage {

  AdvancedSettingsPage(BuildContext context, {bool isPartial = false}) : super(
      title: S.of(context).advanced,
      pageState: AdvancedSettingsPageState(),
      isPartial: isPartial
  );

}

class AdvancedSettingsPageState extends SettingsPageState {

  int _maxConcurrentRequests;
  int _requestTimeout;

  @override
  void initState() {
    () async {
      _maxConcurrentRequests = await Settings.maxConcurrentRequests;
      _requestTimeout = await Settings.requestTimeout;
      setState(() {});
    }();
    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return ListView(
      physics: widget.isPartial ? NeverScrollableScrollPhysics() : null,
      shrinkWrap: widget.isPartial ? true : false,
      children: <Widget>[
        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText(S.of(context).change_default_server),
            subtitle: Text(S.of(context).manually_override_the_default_content_server),
            enabled: true,
            onTap: (){

            },
          ),
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            isThreeLine: true,
            title: TitleText("Maximum Concurrent Requests"),
            subtitle: Text("Limits the number of concurrent network requests that can be made by the app."),
            enabled: true,
            trailing: DropdownButton<int>(
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'GlacialIndifference',
                  fontSize: 16
                ),
                hint: Text(_maxConcurrentRequests.toString(), style: TextStyle(
                  color: Colors.white
                )),
                // Max value for 'Maximum concurrent requests' -> 5
                items: List<DropdownMenuItem<int>>.generate(5, (value){
                  value += 1;
                  return DropdownMenuItem<int>(
                    child: Text(value.toString()),
                    value: value
                  );
                }),
                onChanged: (value){
                  Settings.maxConcurrentRequests = value;
                  setState(() {
                    _maxConcurrentRequests = value;
                  });
                }
            ),
          ),
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            isThreeLine: true,
            title: TitleText("Request Timeout Duration"),
            subtitle: Text("The delay, in seconds, before which a network request will be timed out."),
            enabled: true,
            trailing: DropdownButton<int>(
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'GlacialIndifference',
                    fontSize: 16
                ),
                hint: Text(_requestTimeout.toString(), style: TextStyle(
                    color: Colors.white
                )),
                // Generate 5 items (in this case - interval of 10)
                items: List<DropdownMenuItem<int>>.generate(5, (value){
                  value = (value + 1) * 10;
                  return DropdownMenuItem<int>(
                      child: Text(value.toString()),
                      value: value
                  );
                }),
                onChanged: (value){
                  Settings.requestTimeout = value;
                  setState(() {
                    _requestTimeout = value;
                  });
                }
            ),
          ),
        ),

        Divider(),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText(S.of(context).run_connectivity_test),
            subtitle: Text(S.of(context).checks_whether_sources_can_be_reached),
            enabled: true,
            onTap: () => {},
          ),
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            title: TitleText(S.of(context).get_device_information),
            subtitle: Text(S.of(context).gathers_useful_information_for_debugging),
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
                Interface.showSnackbar(S.of(context).link_copied_to_clipboard, context: context);

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
