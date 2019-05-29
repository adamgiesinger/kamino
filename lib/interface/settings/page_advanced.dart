import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/interface/intro/kamino_intro.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/elements.dart';
import 'package:kamino/ui/interface.dart';
import 'package:kamino/interface/settings/page.dart';
import 'package:device_info/device_info.dart';
import 'package:kamino/util/database_helper.dart';
import 'package:kamino/util/settings.dart';


class AdvancedSettingsPage extends SettingsPage {

  AdvancedSettingsPage(BuildContext context, {bool isPartial = false}) : super(
      title: S.of(context).advanced,
      pageState: AdvancedSettingsPageState(),
      isPartial: isPartial
  );

}

class AdvancedSettingsPageState extends SettingsPageState {

  ScrollController _scrollView = new ScrollController();

  bool _disableSecurityMessages = false;
  bool _showDebugItems = false;

  final _serverURLController = TextEditingController();
  final _serverKeyController = TextEditingController();

  @override
  void initState() {
    assert((){
      _showDebugItems = true;
      return true;
    }());

    () async {
      _serverURLController.text = await Settings.serverURLOverride;
      _serverKeyController.text = await Settings.serverKeyOverride;
      _disableSecurityMessages = await Settings.disableSecurityMessages;

      setState(() {});
    }();

    super.initState();
  }

  @override
  Widget buildPage(BuildContext context) {
    return ListView(
      controller: _scrollView,
      physics: widget.isPartial ? NeverScrollableScrollPhysics() : null,
      shrinkWrap: widget.isPartial ? true : false,
      children: <Widget>[

        SubtitleText(S.of(context).core, padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15).copyWith(bottom: 5)),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            leading: Icon(Icons.dns),
            title: TitleText(S.of(context).change_default_server),
            subtitle: Text(S.of(context).manually_override_the_default_content_server),
            enabled: true,
            onTap: (){
              showDialog(context: context, builder: (BuildContext context){
                return AlertDialog(
                  title: TitleText(S.of(context).change_default_server),
                  contentPadding: EdgeInsets.all(0),

                  content: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                    child: SizedBox(
                      width: 500,
                      height: 230,
                      child: Form(
                        autovalidate: true,
                        child: ListView(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Text(S.of(context).be_careful_this_option_could_break_the_app_if_you),
                            ),

                            !_disableSecurityMessages ? Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: RichText(text: TextSpan(children: [
                                TextSpan(text: "SECURITY RISK:", style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: " "),
                                TextSpan(text: "Using unofficial servers can expose your IP address. If this is a concern, you should use a VPN.")
                              ], style: TextStyle(
                                  color: Colors.red
                              ))),
                            ) : Container(),

                            /** PRESETS **/
                            /*Container(
                              height: 35,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: SubtitleText("Presets:", padding: EdgeInsets.all(0).copyWith(right: 20)),
                                  ),
                                  FlatButton(
                                    onPressed: (){
                                      setState(() {
                                        _serverURLController.text = "https://claws.ddivad.dev/";
                                        _serverKeyController.text = "W6C5AZPxDSWx58cPELhXrgLXtHTnNP9x";
                                      });
                                    },
                                    child: Text("ddivad"),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100)
                                    ),
                                    color: Colors.white12,
                                  )
                                ],
                              ),
                            ),*/

                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: TextFormField(
                                validator: (String arg){
                                  const String serverURLRegex = r"^(http|https):\/\/(([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])\.)*([a-z0-9]|[a-z0-9][a-z0-9\-]*[a-z0-9])(:[0-9]+)?\/$";
                                  bool isValid = new RegExp(serverURLRegex, caseSensitive: false).hasMatch(arg);
                                  if(!isValid && arg.length > 0) return S.of(context).the_url_must_be_valid_and_include_a_trailing_;
                                },
                                controller: _serverURLController,
                                keyboardType: TextInputType.url,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.public),
                                    labelText: S.of(context).server_url
                                ),
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: TextFormField(
                                validator: (String arg){
                                  if(arg.length != 32 && arg.length > 0)
                                    return S.of(context).the_key_must_be_32_characters_in_length;
                                },
                                maxLength: 32,
                                maxLengthEnforced: true,
                                controller: _serverKeyController,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.vpn_key),
                                    labelText: S.of(context).server_key
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  actions: <Widget>[
                    FlatButton(
                      child: Text(S.of(context).reset),
                      onPressed: () async {
                        _serverURLController.text = "";
                        _serverKeyController.text = "";

                        setState((){});
                      },
                    ),

                    FlatButton(
                      child: Text(S.of(context).cancel),
                      onPressed: () => Navigator.of(context).pop(),
                    ),

                    FlatButton(
                      child: Text(S.of(context).set),
                      onPressed: () async {
                        (_serverURLController.text != "") ? Settings.serverURLOverride = _serverURLController.text : SettingsManager.deleteKey("serverURLOverride");
                        (_serverKeyController.text != "") ? Settings.serverKeyOverride = _serverKeyController.text : SettingsManager.deleteKey("serverKeyOverride");

                        setState((){});
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
            },
          ),
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            leading: Icon(Icons.phonelink_setup),
            title: TitleText(S.of(context).run_initial_setup_procedure),
            subtitle: Text(S.of(context).begins_the_initial_setup_procedure_that_is_displayed_when_the),
            enabled: true,
            isThreeLine: true,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => KaminoIntro()
            )),
            onLongPress: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => KaminoIntro(skipAnimation: true)
            )),
          ),
        ),

        SubtitleText(S.of(context).networking, padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15).copyWith(bottom: 5)),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            leading: Icon(Icons.settings_ethernet),
            title: TitleText(S.of(context).run_connectivity_test),
            subtitle: Text(S.of(context).checks_whether_sources_can_be_reached),
            enabled: true,
            onTap: (){
              showDialog(context: context, builder: (BuildContext context){
                return AlertDialog(
                  title: TitleText(S.of(context).not_yet_implemented),
                  content: Text(S.of(context).this_feature_has_not_yet_been_implemented),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(S.of(context).okay),
                      textColor: Theme.of(context).primaryColor,
                    )
                  ],
                );
              });
            },
          ),
        ),

        SubtitleText(S.of(context).diagnostics, padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15).copyWith(bottom: 5)),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            leading: Icon(Icons.code),
            title: TitleText("Run Command"),
            enabled: true,
            onTap: () async {
              Interface.showSnackbar("Waiting for input...", context: context);
              KaminoAppState application = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());
              application.getPrimaryVendorConfig().beginExecCommand('init_debug');
            }
          )
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            leading: Icon(Icons.perm_device_information),
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

                try {
                  var response = await http.post("https://hastebin.com/documents", body: info);
                  String key = jsonDecode(response.body)["key"];

                  await Clipboard.setData(new ClipboardData(text: "https://hastebin.com/$key.apollodebug"));
                  Interface.showSnackbar(S.of(context).link_copied_to_clipboard, context: context);
                }catch(ex){
                  if(ex is SocketException || ex is HttpException)
                    Interface.showSnackbar(S.of(context).youre_offline, context: context, backgroundColor: Colors.red);
                  Interface.showSnackbar(S.of(context).an_error_occurred, context: context, backgroundColor: Colors.red);
                }

                return;
              }

              /*if(Platform.isIOS){
                print(await deviceInfo.iosInfo);
                return;
              }*/
            },
          ),
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            leading: Icon(Icons.delete_forever),
            title: TitleText(S.of(context).wipe_database),
            subtitle: Text(S.of(context).clears_the_application_database),
            enabled: true,
            onTap: () async {
              Interface.showLoadingDialog(context, title: S.of(context).wiping_database);
              await DatabaseHelper.wipe();
              Navigator.of(context).pop();
            },
          ),
        ),

        Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            leading: Icon(Icons.layers_clear),
            title: TitleText(S.of(context).wipe_settings),
            subtitle: Text(S.of(context).clears_all_application_settings),
            enabled: true,
            onTap: () async {
              Interface.showLoadingDialog(context, title: S.of(context).clearing_settings);
              await SettingsManager.eraseAllSettings();
              Navigator.of(context).pop();
            },
          ),
        ),

        _showDebugItems ? Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            leading: Icon(Icons.sd_storage),
            title: TitleText(S.of(context).dump_preferences),
            subtitle: Text(S.of(context).debug_only_logs_the_application_preferences_in_the_console),
            enabled: true,
            onTap: () => SettingsManager.dumpFromStorage(),
          ),
        ) : Container(),

        _showDebugItems ? Material(
          color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
          child: ListTile(
            leading: Icon(Icons.storage),
            title: TitleText(S.of(context).dump_database),
            subtitle: Text(S.of(context).debug_only_logs_the_application_database_in_the_console),
            enabled: true,
            onTap: () => DatabaseHelper.dump(),
          ),
        ) : Container(),

        SubtitleText("Security", padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15).copyWith(bottom: 5)),

        Material(
            color: widget.isPartial ? Theme.of(context).cardColor : Theme.of(context).backgroundColor,
            child: SwitchListTile(
              activeColor: Theme.of(context).primaryColor,
              secondary: Icon(Icons.warning),
              title: TitleText("Disable Security Warnings"),
              subtitle: RichText(text: TextSpan(
                children: [
                  TextSpan(text: "\n"),
                  TextSpan(text: "This disables all warnings regarding potential security concerns."),
                  if(!_disableSecurityMessages)
                    TextSpan(text: "\n\nWe recommend that you do not enable this option unless you are positive that you know what you're doing.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))
                  else
                    TextSpan(text: "\n\nSecurity warnings have been disabled!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))
                ]
              )),
              value: _disableSecurityMessages,
              onChanged: (bool value) async {
                await (Settings.disableSecurityMessages = value);
                Settings.disableSecurityMessages.then((data){
                  setState(() {
                    _disableSecurityMessages = data;

                    if(!_disableSecurityMessages){
                      _scrollView.animateTo(
                        _scrollView.offset + 40,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 400)
                      );
                    }
                  });
                });
              }
            )
        ),

        Container(margin: EdgeInsets.only(top: 20))
      ],
    );
  }

}
