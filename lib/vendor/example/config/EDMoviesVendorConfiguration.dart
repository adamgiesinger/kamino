/*
   EDMovies - ApolloTV fictional vendor configuration.
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kamino/vendor/struct/VendorConfiguration.dart';

import 'package:cplayer/cplayer.dart';

class EDMoviesVendorConfiguration extends VendorConfiguration {

  static const _tmdb_api_key = "";

  String _token;

  EDMoviesVendorConfiguration() : super(
    // This is the
      name: "EDMovies",

      // If you are using Claws, this is the address of your Claws instance,
      // including the port, protocol and trailing slash.
      // For example: https://claws.edmovies.com/
      server: "",

      // This will reference the constant that you made.
      tmdb_api_key: _tmdb_api_key
  );

  ///******* COMMUNICATION *******///
  /// From this point, all methods are related to handling communication with
  /// external services such as authenticating with the server: [authenticate].

  ///
  /// If you're communicating with a server that requires authentication,
  /// you should use this method.
  ///
  /// This does not return the token or key used for authentication.
  /// We recommend that you check and accordingly update the [_token] variable.
  /// Especially if you use cryptographic methods to authenticate with your server.
  ///
  Future<bool> authenticate() async {
    // TODO: Authenticate with server

    // If you do not need to authenticate, just return true.
    return true;
  }

  ///******* ACTIONS *******///
  /// From this point, all methods are related to performing an action
  /// such as [playMovie] or [playTVShow].

  /// Plays a movie based on the movie's [title]. The BuildContext, [context],
  /// is used to close any loading dialogs as well as to push the [CPlayer]
  /// instance onto the current application's [Navigator] stack.
  Future<void> playMovie(String title, BuildContext context) async {
    await authenticate();

    // TODO: Start playing the content.
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              title: Text("TODO"),
              content: Text("You need to implement the playMovie() method in your vendor configuration.")
          );
        }
    );
  }


  /// Plays an episode of a TV show based on its [title], [releaseDate],
  /// seasonNumber] and [episodeNumber]. The BuildContext, [context], is used to
  /// close any loading dialogs as well as to push the [CPlayer]
  /// instance onto the current application's [Navigator] stack.
  Future<void> playTVShow(String title, String releaseDate, int seasonNumber, int episodeNumber, BuildContext context) async {
    await authenticate();
    String contentTitle = _formatTVShowTitle(title, releaseDate);

    // TODO: Start playing the content.
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
              title: Text("TODO"),
              content: Text("You need to implement the playTVShow() method in your vendor configuration.")
          );
        }
    );
  }

  /// (Optional) Format title
  /// Depending on how your sources are organized, this is sometimes helpful.
  /// It will re-arrange the title into the format "Title (yyyy)".
  ///
  /// In order for this to happen, it must be provided with the [title] (String)
  /// and the release date of the content [releaseDate], an ISO 8601 string.
  /// The date string's highest accuracy is the date so it will normally be in
  /// the format yyyy-mm-dd
  String _formatTVShowTitle(String title, String releaseDate){
    var year = new DateFormat.y("en_US").format(DateTime.parse(releaseDate));
    return "$title ($year)";
  }

}
