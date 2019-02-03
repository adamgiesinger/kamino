import 'dart:io';

import 'package:flutter_user_agent/flutter_user_agent.dart';

/// Global http override settings.
class ClawsHttpOverrides extends HttpOverrides {
  String userAgent;

  ClawsHttpOverrides(this.userAgent);

  @override
  HttpClient createHttpClient(SecurityContext context) {
    var httpClient = super.createHttpClient(context);
    httpClient.userAgent = userAgent;
    httpClient.connectionTimeout = Duration(seconds: 5);
    httpClient.idleTimeout = Duration(seconds: 15);

    return httpClient;
  }
}

/// Apply global http overrides.
applyHttpOverrides() async {
  await FlutterUserAgent.init();
  // Apply the device's native user agent for all requests when requesting
  // rather than sending "Dart/<dart_version> (dart:io)"
  HttpOverrides.global = new ClawsHttpOverrides(FlutterUserAgent.webViewUserAgent);
}
