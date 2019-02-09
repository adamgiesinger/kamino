/*
   EDMovies - ApolloTV fictional vendor configuration.
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino/vendor/struct/ClawsVendorConfiguration.dart';

import 'package:cplayer/cplayer.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';

class EDMoviesVendorConfiguration extends ClawsVendorConfiguration {

  EDMoviesVendorConfiguration() : super(
      /// The name of the vendor. If you are developing this independently,
      /// use your GitHub name.
      name: "EDMovies",

      // If you are using Claws, this is the address of your Claws instance,
      // including the port, protocol and trailing slash.
      // For example: https://claws.edmovies.com/
      server: "",

      /// These next options are not mandatory unless this configuration is the
      /// primary configuration.
      tmdbKey: "",
      clawsKey: "",

      traktCredentials: TraktCredentials(
        id: "",
        secret: ""
      )
  );

}
