import 'package:kamino/vendor/index.dart';

const root_url = "https://api.themoviedb.org/3";
const image_cdn = "https://image.tmdb.org/t/p/w500";

/// You will need to define the API key in your vendor configuration file.
/// Check our documentation for more information.
var defaultArguments = "?api_key=${ApolloVendor.getTMDBKey()}&language=en-US";