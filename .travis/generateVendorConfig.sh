#!/bin/bash
TMDB_KEY="$1"
TRAKT_ID="$2"
TRAKT_SECRET="$3"
CLAWS_SERVER_BETA="$4"
CLAWS_KEY_BETA="$5"

cat <<____HERE
/*
   Travis-CI - ApolloTV automated vendor configuration.
*/

import 'package:kamino/vendor/services/ClawsVendorService.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';

class OfficialVendorConfiguration extends VendorConfiguration {

  OfficialVendorConfiguration() : super(
      /// The name of the vendor. If you are developing this independently,
      /// use your GitHub name.
      name: "Official (Automated)",

      /// If you are using Claws, this is a [ClawsVendorService],
      /// including the port, protocol and trailing slash.
      /// For example: https://claws.edmovies.com/
      service: ClawsVendorService(
          server: "http://beta.apollotv.xyz/",

          // This is the key you set on the server.
          // It should be 32 characters long.
          clawsKey: "`echo $CLAWS_KEY_BETA`",

          isOfficial: true,

          // This option allows you to enable the manually select
          // sources option.
          allowSourceSelection: true
      ),

      /// These next options are not mandatory unless this configuration is the
      /// primary configuration.
      tmdbKey: "`echo $TMDB_KEY`",
      traktCredentials: TraktCredentials(
        id: "`echo $TRAKT_ID`",
        secret: "`echo $TRAKT_SECRET`"
      )
  );

}
____HERE
