import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mdns_plugin/flutter_mdns_plugin.dart';

class CastServiceDiscovery extends ChangeNotifier {

  FlutterMdnsPlugin _flutterMdnsPlugin;
  List<ServiceInfo> foundServices;

  CastServiceDiscovery() {
    _flutterMdnsPlugin = FlutterMdnsPlugin(
        discoveryCallbacks: DiscoveryCallbacks(
            onDiscoveryStarted: () {
              foundServices = [];
            },
            onDiscoveryStopped: () => {},
            onDiscovered: (ServiceInfo serviceInfo) => {},
            onResolved: (ServiceInfo serviceInfo) {
              if(foundServices == null) return;

              foundServices.add(serviceInfo);
              notifyListeners();
            }
        )
    );

  }

  startDiscovery() {
    _flutterMdnsPlugin.startDiscovery('_googlecast._tcp');
  }

  stopDiscovery() {
    runZoned(() {
      _flutterMdnsPlugin.stopDiscovery();
    }, onError: (error) {});
  }
}