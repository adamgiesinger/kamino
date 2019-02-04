import 'package:flutter/widgets.dart';
import 'package:kamino/vendor/struct/ClawsVendorConfiguration.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';

/// Local client-side vendor configuration that can be passed into the
/// BaseOfficialVendorConfiguration as a delegate.
///
/// This is a delegate as the addition of a client-side resolver can increase
/// the output binary file-size considerably.
abstract class LocalVendorConfiguration {
  ///
  /// Play certain media types.
  Future<VendorSubscription> playMedia(String mediaType, Map<String, String> query, BuildContext context);

  void setVendorConfiguration(ClawsVendorConfiguration configuration);
}