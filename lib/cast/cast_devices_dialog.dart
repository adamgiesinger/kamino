import 'package:dart_chromecast/casting/cast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mdns_plugin/flutter_mdns_plugin.dart';
import 'package:kamino/cast/cast_service_discovery.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/ui/elements.dart';

class CastDevicesDialog {

  static Future<CastDevice> show(BuildContext context) async {
    return await showDialog<CastDevice>(context: context, barrierDismissible: true, builder: (BuildContext context){
      return CastDevicesDialogWrapper();
    });
  }

}

class CastDevicesDialogWrapper extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => CastDevicesDialogWrapperState();

}

class CastDevicesDialogWrapperState extends State<CastDevicesDialogWrapper>{

  CastServiceDiscovery serviceDiscovery;
  List<ServiceInfo> castServices;
  Function serviceDiscoveryListener;

  @override
  void initState() {
    castServices = [];
    serviceDiscovery = new CastServiceDiscovery();

    serviceDiscoveryListener = (){
      castServices = serviceDiscovery.foundServices;
      if(mounted) setState(() {});
    };
    serviceDiscovery.addListener(serviceDiscoveryListener);

    serviceDiscovery.startDiscovery();
    super.initState();
  }

  @override
  void dispose() {
    serviceDiscovery.removeListener(serviceDiscoveryListener);
    serviceDiscovery.stopDiscovery();
    serviceDiscovery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TitleText("Select Cast Device"),
          InkWell(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100)
              ),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.refresh),
            ),
            onTap: (){
              serviceDiscovery.stopDiscovery();
              setState(() {
                castServices = [];
              });
              serviceDiscovery.startDiscovery();
            },
          )
        ],
      ),
      children: castServices != null && castServices.length > 0 ? List.generate(castServices.length, (int index){
        ServiceInfo castService = castServices[index];
        CastDevice device = new CastDevice(
          name: castService.name,
          type: castService.type.replaceFirst(".", ""),
          host: castService.hostName,
          port: castService.port,
          attr: castService.attr
        );

        return SimpleDialogOption(
          onPressed: () async {
            Navigator.of(context).pop(device);
          },
          child: ListTile(
            leading: Icon(Icons.tv),
            title: TitleText(device.friendlyName),
            subtitle: Text(device.modelName ?? S.of(context).unknown_model),
          ),
        );
      }) : [
        Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TitleText(S.of(context).searching_for_cast_devices),
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20
                ),
                child: SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      backgroundColor: Theme.of(context).cardColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor
                      ),
                    )
                ),
              )
            ],
          ),
        )
      ],
    );
  }

}