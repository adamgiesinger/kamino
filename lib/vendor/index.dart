import 'package:kamino/vendor/dist/config/OfficialVendorConfiguration.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';

class ApolloVendor {
  static List<VendorConfiguration> getVendorConfigs(){
    return [
      // The main vendor configuration is always vendorConfigs[0].
      // You should change this to your preferred vendor configuration.
      new OfficialVendorConfiguration()

      // The rest are secondary vendor configurations...
    ];
  }

}
