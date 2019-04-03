
import 'package:flutter/material.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';

class ClawsVendorService extends VendorConfiguration {

  @override
  Future<bool> authenticate(BuildContext context, {bool force = false}) {
    // TODO: implement authenticate
    return null;
  }

  @override
  Future<void> playMovie(String title, String releaseDate, BuildContext context) {
    // TODO: implement playMovie
    return null;
  }

  @override
  Future<void> playTVShow(String title, String releaseDate, int seasonNumber, int episodeNumber, BuildContext context) {
    // TODO: implement playTVShow
    return null;
  }



}