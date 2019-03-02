import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes

// This file is automatically generated. DO NOT EDIT, all your changes would be lost.
class S implements WidgetsLocalizations {
  const S();

  static const GeneratedLocalizationsDelegate delegate =
    GeneratedLocalizationsDelegate();

  static S of(BuildContext context) => Localizations.of<S>(context, S);

  @override
  TextDirection get textDirection => TextDirection.ltr;

  String get added_to_favorites => "Added to favorites";
  String get advanced => "Advanced";
  String get air_date => "Air date";
  String get appearance => "Appearance";
  String get ascending => "Ascending";
  String get authentication_successful => "Authentication Successful";
  String get authentication_unsuccessful => "Authentication Unsuccessful";
  String get blog => "Blog";
  String get boost_your_experience => "BOOST YOUR EXPERIENCE";
  String get cancel => "Cancel";
  String get change_default_server => "Change Default Server";
  String get change_theme => "Change Theme...";
  String get check_for_updates => "Check for Updates";
  String get checks_whether_sources_can_be_reached => "Checks whether sources can be reached.";
  String get clear_search_history => "Clear Search History";
  String get clear_search_history_description => "Removes search suggestions based on past searches.";
  String get coming_soon => "Coming Soon";
  String get connect => "Connect";
  String get customise_the_theme_and_primary_colors => "Customise the theme and primary colors.";
  String get customise_your_launchpad => "Customise your launchpad.";
  String get default_ => "Default";
  String get descending => "Descending";
  String get detailed_content_information => "Detailed Content Information";
  String get detailed_content_information_description => "Replaces the grid of posters with a list of more detailed cards on search and overview pages.";
  String get disconnect => "Disconnect";
  String get disconnected_trakt_account => "Disconnected Trakt account.";
  String get dismiss => "Dismiss";
  String get donate => "Donate";
  String get done => "Done";
  String get downloading_update_file => "Downloading update file...";
  String get error_updating_app => "Error updating app...";
  String get extensions => "Extensions";
  String get favorites => "Favorites";
  String get gathers_useful_information_for_debugging => "Gathers useful information for debugging.";
  String get general_application_settings => "General application settings.";
  String get get_device_information => "Get Device Information";
  String get launchpad => "Launchpad";
  String get legal => "Legal";
  String get link_copied_to_clipboard => "Link copied to clipboard.";
  String get loading => "Loading...";
  String get manage_third_party_integrations => "Manage third party integrations.";
  String get manually_override_the_default_content_server => "Manually override the default content server.";
  String get manually_select_sources => "Manually Select Sources";
  String get manually_select_sources_description => "Shows a dialog with a list of discovered sources instead of automatically choosing one.";
  String get miscellaneous => "MISCELLANEOUS";
  String get movies => "Movies";
  String get no_results_found => "No results found.";
  String get okay => "Okay";
  String get one_episode => "1 episode";
  String get ongoing => "Ongoing";
  String get order => "ORDER";
  String get other_ => "Other";
  String get permission_denied => "Permission denied.";
  String get play_episode => "Play Episode";
  String get play_movie => "Play Movie";
  String get popularity => "Popularity";
  String get power_user_settings_for_rocket_scientists => "Power user settings for rocket scientists.";
  String get rd_description => "Real-Debrid is an unrestricted downloader that allows you to quickly download files hosted on the Internet.";
  String get released => "Released";
  String get removed_from_favorites => "Removed from favorites";
  String get restore_defaults => "Restore Defaults";
  String get run_connectivity_test => "Run Connectivity Test";
  String get search_history_cleared => "Search history cleared.";
  String get search_tv_shows_and_movies => "Search TV shows and movies...";
  String get set_primary_color => "Set Primary Color...";
  String get settings => "Settings";
  String get show_less => "Show less...";
  String get show_more => "Show more...";
  String get similar_movies => "Similar Movies";
  String get sort => "Sort";
  String get successfully_refreshed_trakt_token => "Successfully refreshed Trakt token.";
  String get sync => "Sync";
  String get synopsis => "Synopsis";
  String get the_default_configuration_has_been_restored => "The default configuration has been restored.";
  String get trakt_authenticator => "Trakt Authenticator";
  String get trakt_description => "Automatically track what you're watching, synchronise playlists across devices and more...";
  String get trakt_favorites_sync_detailed => "Please wait while we synchronize your favorites with Trakt. This dialog will close automatically when synchronization is complete.";
  String get trakt_renewal_failure_detailed => "Failed to renew Trakt token. Please check your details.";
  String get trakt_synchronization => "Trakt Synchronization...";
  String get tv_shows => "TV Shows";
  String get unknown => "Unknown";
  String get update_failed_please_try_again_later => "Update failed. Please try again later.";
  String get update_failed_storage_permission_denied => "Update failed. Storage permission denied.";
  String get updating => "Updating...";
  String get url_copied => "URL copied!";
  String get vote_average => "Vote Average";
  String get with_thanks => "With thanks...";
  String get you_can_now_tap_sync_to_synchronise_your_trakt_favorites => "You can now tap 'Sync' to synchronise your Trakt favorites with your ApolloTV favorites.\n\n(Trakt integration is limited as it is still in development.)";
  String appname_was_made_possible_by_all_of_these_amazing_people(String appName) => "$appName was made possible by all of these amazing people:";
  String appname_was_unable_to_authenticate_with_trakttv(String appName) => "$appName was unable to authenticate with Trakt.tv.";
  String by_x(String x) => "by $x";
  String general_error(String error) => "An error occurred ($error)\nPlease report this error.";
  String make_appname_yours(String appName) => "MAKE $appName YOURS";
  String n_episodes(String n) => "$n episodes";
  String n_ratings(String n) => "$n ratings";
  String seasons_n(String n) => "Seasons ($n)";
  String this_x_has_no_synopsis_available(String x) => "This $x has no synopsis available.";
  String unknown_x(String x) => "Unknown $x";
}

class $en extends S {
  const $en();
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<S> {
  const GeneratedLocalizationsDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale("en", ""),
    ];
  }

  LocaleListResolutionCallback listResolution({Locale fallback, bool withCountry = true}) {
    return (List<Locale> locales, Iterable<Locale> supported) {
      if (locales == null || locales.isEmpty) {
        return fallback ?? supported.first;
      } else {
        return _resolve(locales.first, fallback, supported, withCountry);
      }
    };
  }

  LocaleResolutionCallback resolution({Locale fallback, bool withCountry = true}) {
    return (Locale locale, Iterable<Locale> supported) {
      return _resolve(locale, fallback, supported, withCountry);
    };
  }

  @override
  Future<S> load(Locale locale) {
    final String lang = getLang(locale);
    if (lang != null) {
      switch (lang) {
        case "en":
          return SynchronousFuture<S>(const $en());
        default:
          // NO-OP.
      }
    }
    return SynchronousFuture<S>(const S());
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale, true);

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;

  ///
  /// Internal method to resolve a locale from a list of locales.
  ///
  Locale _resolve(Locale locale, Locale fallback, Iterable<Locale> supported, bool withCountry) {
    if (locale == null || !_isSupported(locale, withCountry)) {
      return fallback ?? supported.first;
    }

    final Locale languageLocale = Locale(locale.languageCode, "");
    if (supported.contains(locale)) {
      return locale;
    } else if (supported.contains(languageLocale)) {
      return languageLocale;
    } else {
      final Locale fallbackLocale = fallback ?? supported.first;
      return fallbackLocale;
    }
  }

  ///
  /// Returns true if the specified locale is supported, false otherwise.
  ///
  bool _isSupported(Locale locale, bool withCountry) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        // Language must always match both locales.
        if (supportedLocale.languageCode != locale.languageCode) {
          continue;
        }

        // If country code matches, return this locale.
        if (supportedLocale.countryCode == locale.countryCode) {
          return true;
        }

        // If no country requirement is requested, check if this locale has no country.
        if (true != withCountry && (supportedLocale.countryCode == null || supportedLocale.countryCode.isEmpty)) {
          return true;
        }
      }
    }
    return false;
  }
}

String getLang(Locale l) => l == null
  ? null
  : l.countryCode != null && l.countryCode.isEmpty
    ? l.languageCode
    : l.toString();
