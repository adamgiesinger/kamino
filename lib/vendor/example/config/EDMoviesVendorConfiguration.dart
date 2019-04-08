/*
   EDMovies - ApolloTV fictional vendor configuration.
*/

import 'package:kamino/vendor/services/ClawsVendorService.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';

class EDMoviesVendorConfiguration extends VendorConfiguration {

  EDMoviesVendorConfiguration() : super(
      /// The name of the vendor. If you are developing this independently,
      /// use your GitHub name.
      name: "EDMovies",

      /// If you are using Claws, this is a [ClawsVendorService],
      /// including the port, protocol and trailing slash.
      /// For example: https://claws.edmovies.com/
      service: ClawsVendorService(
          server: "http://localhost:3000/",

          // This is the key you set on the server.
          // It should be 32 characters long.
          clawsKey: "",

          // This option allows you to enable the manually select
          // sources option.
          allowSourceSelection: true
      ),

      /// These next options are not mandatory unless this configuration is the
      /// primary configuration.
      tmdbKey: "",
      traktCredentials: TraktCredentials(
        id: "",
        secret: ""
      )
  );

}
