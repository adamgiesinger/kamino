/*
   EDMovies - ApolloTV fictional vendor configuration.
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino/vendor/struct/ClawsVendorConfiguration.dart';

import 'package:cplayer/cplayer.dart';

class EDMoviesVendorConfiguration extends ClawsVendorConfiguration {

  static const _tmdb_api_key = "";
  static const _claws_api_key = "";

  EDMoviesVendorConfiguration() : super(
      /// The name of the vendor. If you are developing this independently,
      /// use your GitHub name.
      name: "EDMovies",

      // If you are using Claws, this is the address of your Claws instance,
      // including the port, protocol and trailing slash.
      // For example: https://claws.edmovies.com/
      server: "",

      // This will reference the constant that you made.
      tmdbKey: _tmdb_api_key,
      clawsKey: _claws_api_key
  );

}
