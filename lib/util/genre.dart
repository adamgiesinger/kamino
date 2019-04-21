import 'package:kamino/models/content.dart';

class Genre {

  static const List movie = [
    {
      "id": 28,
      "name": "Action"
    },
    {
      "id": 12,
      "name": "Adventure"
    },
    {
      "id": 16,
      "name": "Animation"
    },
    {
      "id": 35,
      "name": "Comedy"
    },
    {
      "id": 80,
      "name": "Crime"
    },
    {
      "id": 99,
      "name": "Documentary"
    },
    {
      "id": 18,
      "name": "Drama"
    },
    {
      "id": 10751,
      "name": "Family"
    },
    {
      "id": 14,
      "name": "Fantasy"
    },
    {
      "id": 36,
      "name": "History"
    },
    {
      "id": 27,
      "name": "Horror"
    },
    {
      "id": 10402,
      "name": "Music"
    },
    {
      "id": 9648,
      "name": "Mystery"
    },
    {
      "id": 10749,
      "name": "Romance"
    },
    {
      "id": 878,
      "name": "Science Fiction"
    },
    {
      "id": 10770,
      "name": "TV Movie"
    },
    {
      "id": 53,
      "name": "Thriller"
    },
    {
      "id": 10752,
      "name": "War"
    },
    {
      "id": 37,
      "name": "Western"
    }
  ];

  static const List tv = [
    {
      "id": 10759,
      "name": "Action & Adventure",
      "banner": ""
    },
    {
      "id": 16,
      "name": "Animation",
      "banner": ""
    },
    {
      "id": 35,
      "name": "Comedy",
      "banner": ""
    },
    {
      "id": 80,
      "name": "Crime",
      "banner": ""
    },
    {
      "id": 99,
      "name": "Documentary",
      "banner": ""
    },
    {
      "id": 18,
      "name": "Drama",
      "banner": ""
    },
    {
      "id": 10751,
      "name": "Family",
      "banner": ""
    },
    {
      "id": 10762,
      "name": "Kids",
      "banner": ""
    },
    {
      "id": 9648,
      "name": "Mystery",
      "banner": ""
    },
    {
      "id": 10763,
      "name": "News",
      "banner": ""
    },
    {
      "id": 10764,
      "name": "Reality",
      "banner": ""
    },
    {
      "id": 10765,
      "name": "Sci-Fi & Fantasy",
      "banner": ""
    },
    {
      "id": 10767,
      "name": "Talk",
      "banner": ""
    },
    {
      "id": 10768,
      "name": "War & Politics",
      "banner": ""
    },
    {
      "id": 37,
      "name": "Western",
      "banner": ""
    }
  ];

  static String getFontImagePath(ContentType content, int genreId){
    String mediaType = content == ContentType.TV_SHOW ? "tv" : "movie";
    return "assets/genre/${getRawContentType(content)}/${resolveGenreName(mediaType, genreId)}.svg";
  }

  static String resolveGenreName(String mediaType, int genreId){
    switch(mediaType){
      case 'tv':
        return Genre.tv.firstWhere((genre) => genre['id'] == genreId)['name'];
      case 'movie':
        return Genre.movie.firstWhere((genre) => genre['id'] == genreId)['name'];
      default:
        return null;
    }
  }

}

List<String> resolveGenreNames(List genreIds, String mediaType) {

  Function getNames = (genres) => genres.where(
          (genre) => genreIds.contains(genre['id'])
  ).map((genre) => genre['name']).toList().cast<String>();

  switch(mediaType){
    case 'tv':
      return getNames(Genre.tv);
    case 'movie':
      return getNames(Genre.movie);
    default:
      return [];
  }

}