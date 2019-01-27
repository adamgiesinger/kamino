import 'package:flutter/widgets.dart';
import 'package:kamino/vendor/struct/BaseOfficialVendorConfiguration.dart';

/// Local client-side vendor configuration that can be passed into the
/// BaseOfficialVendorConfiguration as a delegate.
///
/// This is a delegate as the addition of a client-side resolver can increase
/// the output binary file-size considerably.
abstract class LocalVendorConfiguration {
  Future<LocalVendorSubscription> playMovie(String title, BuildContext context);

  Future<LocalVendorSubscription> playTVShow(String name, String releaseDate, int seasonNumber,
      int episodeNumber, BuildContext context);

  void setVendorConfiguration(BaseOfficialVendorConfiguration configuration);
}

abstract class LocalVendorSubscription {
  Future<dynamic> disconnect();
}