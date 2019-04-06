import 'package:flutter/material.dart';
import 'package:kamino/vendor/struct/VendorService.dart';
import 'package:meta/meta.dart';

abstract class VendorConfiguration {

  final String name;
  final VendorService service;

  final String _tmdbKey;
  final TraktCredentials _traktCredentials;

  ///
  /// A VendorConfiguration should be used to change the default settings in the
  /// ApolloTV app. Simply create your own class and extend [VendorConfiguration].
  ///
  /// [name] - The name of the vendor. If you are developing this independently,
  ///           use your GitHub name.
  ///
  /// [service] - The service implementation for this vendor.
  ///
  VendorConfiguration({
    @required this.name,
    @required this.service,

    String tmdbKey,
    TraktCredentials traktCredentials
  }) :
      _tmdbKey = tmdbKey,
      _traktCredentials = traktCredentials;

  ///
  /// Returns the name of the Vendor, as provided when the configuration object
  /// was initialized.
  ///
  String getName(){
    return name;
  }

  String getTMDBKey(){
    if(_tmdbKey != null){
      return _tmdbKey;
    }else{
      throw new Exception("Vendor ${getName()} does not have a TMDB key.");
    }
  }

  TraktCredentials getTraktCredentials(){
    if(_traktCredentials != null){
      return _traktCredentials;
    }else{
      throw new Exception("Vendor ${getName()} does not have Trakt credentials.");
    }
  }

}

class TraktCredentials {

  String id;
  String secret;

  TraktCredentials({
    @required this.id,
    @required this.secret
  });

}
