import 'package:flutter/material.dart';
import 'package:kamino/main.dart';

class BaseLayout {

  /// Attempt to find media of various types with shared logic for disconnecting
  /// from the search subscription when the user dismisses the search.
  static dynamic findMedia(BuildContext context, String mediaType, Map data) async {
    KaminoAppState appState = context.ancestorStateOfType(const TypeMatcher<KaminoAppState>());
    var vendorConfig = appState.getVendorConfigs()[0];
    switch(mediaType) {
      case 'tv':
        return vendorConfig.playTVShow(
            data['title'],
            data['releaseDate'],
            data['seasonNumber'],
            data['episodeNumber'],
            context
        );
        break;
      case 'movies':
        return vendorConfig.playMovie(
            data['title'],
            context
        );
        break;
      default:
        throw new Exception("Unknown media type: $mediaType");
    }
  }
}