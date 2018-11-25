import 'package:kamino/main.dart';

const root_url = "https://api.themoviedb.org/3";
const image_cdn = "https://image.tmdb.org/t/p/w500";

/// You will need to define the API key in your vendor configuration file.
/// Check our documentation for more information.
var default_arguments = "?api_key=${vendorConfigs[0].getTMDBKey()}&language=en-US";