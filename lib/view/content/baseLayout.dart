import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kamino/main.dart';
import 'package:kamino/ui/uielements.dart';
import 'package:kamino/util/interface.dart';
import 'package:kamino/vendor/struct/LocalOfficialVendorConfiguration.dart';

class BaseLayout {

  /// Attempt to find media of various types with shared logic for disconnecting
  /// from the search subscription when the user dismisses the search.
  static void findMedia(BuildContext context, String mediaType, Map data) async {
    KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());
    var vendorConfig = appState.getVendorConfigs()[0];
    Future subscription;
    switch(mediaType) {
      case 'tv':
        subscription = vendorConfig.playTVShow(
            data['title'],
            data['releaseDate'],
            data['seasonNumber'],
            data['episodeNumber'],
            context
        );
        break;
      case 'movies':
        subscription = vendorConfig.playMovie(
            data['title'],
            context
        );
        break;
      default:
        throw new Exception("Unknown media type: $mediaType");
    }

    Interface.showAlert(
        context,
        new TitleText('Searching for Sources...'),
        [
          Center(
            child: Text("BETA NOTE: If you find yourself waiting more than 30 seconds, there's a good chance we're experiencing server issues."),
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                  child: new CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  )
              )
          )
        ],
        false,
        [Container()]
    ).then((result) {
      // result is null if it was dismissed by the user (e.g. via back button press).
      if (result == null) {
        // Back button was pressed.
        subscription.then((_subscription) {
          // Cancel the event-source subscription when the user closes the
          // alert box so as not to waste resources.
          if (_subscription is StreamSubscription) {
            _subscription.cancel();
          } else if (_subscription is LocalVendorSubscription) {
            _subscription.disconnect();
          }
        });
      }
    });
  }
}