/*
    This is the ApolloVendor configuration file.
    (Location: /lib/vendor/index.dart)
*/

import 'package:kamino/vendor/dist/config/LaunchpadConfiguration.dart';
import 'package:kamino/vendor/struct/ThemeConfiguration.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';
import 'package:kamino/vendor/dist/themes/OfficialVendorThemes.dart';
import 'package:kamino/vendor/dist/config/OfficialVendorConfiguration.dart';

class ApolloVendor {

  static List<VendorConfiguration> getVendorConfigs(){
    return [
      // The main vendor configuration is always list[0].
      // You should change this to your preferred vendor configuration.
      new OfficialVendorConfiguration()

      // The rest are secondary vendor configurations.
      // The priority of the configuration is determined by its position in
      // the list.
    ];
  }

  static List<ThemeConfiguration> getThemeConfigs(){
    return [
      // The main theme configuration is always at index 0.
      // You should change this to your preferred theme configuration.
      OfficialVendorTheme.dark,

      // The rest are secondary theme configurations.
      // They can be chosen by the user.
      OfficialVendorTheme.light,
      OfficialVendorTheme.black
    ];
  }

  static String getTMDBKey(){
    return getVendorConfigs()[0].getTMDBKey();
  }

  ///
  /// This method allows you to define your own configuration file for your
  /// own widgets.
  ///
  /// You either should modify this to return a different LaunchpadConfiguration
  /// or modify the LaunchpadConfiguration.
  ///
  static LaunchpadConfiguration getLaunchpadConfiguration(){
    return LaunchpadConfiguration();
  }

}
