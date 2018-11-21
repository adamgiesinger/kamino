import 'package:kamino/vendor/config/official.dart';

const root_url = "https://api.themoviedb.org/3";
const image_cdn = "https://image.tmdb.org/t/p/w500";

/// You will need to define [tmdb_api_key] in your vendor configuration file.
/// Check our documentation for more information.
const default_arguments = "?api_key=$tmdb_api_key&language=en-US";