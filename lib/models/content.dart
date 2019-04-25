import 'package:flutter/material.dart';

/*  CONTENT TYPE DEFINITIONS  */
enum ContentType { MOVIE, TV_SHOW }
String getPrettyContentType(ContentType type){
  switch(type) {
    case ContentType.MOVIE:
      return "Movie";
    case ContentType.TV_SHOW:
      return "TV Show";
    default:
      return "Unknown";
  }
}

String getRawContentType(ContentType type){
  switch(type) {
    case ContentType.MOVIE:
      return "movie";
    case ContentType.TV_SHOW:
      return "tv";
    default:
      return "unknown";
  }
}

class ContentModel {
  final int id;
  final String imdbId;
  final ContentType contentType;

  // Content Information
  final String title;
  final List<LocalizedTitleModel> alternativeTitles;
  final String originalTitle;
  final String overview;
  final String releaseDate; // For TV shows this is the first release date.
  final String homepage;
  final String originalCountry;

  // Content Classification
  final List genres;
  final double rating;
  final int voteCount;

  // Content Art.
  final String backdropPath;
  final String posterPath;

  // Watch information
  double progress;
  String lastWatched;

  // Videos
  List videos;

  // Cast and Crew
  final List cast;
  final List crew;

  // Recommendations
  final List<ContentModel> recommendations;

  ContentModel({
    @required this.id,
    @required this.title,
    @required this.contentType,
    this.originalTitle,
    this.originalCountry,
    this.alternativeTitles,
    this.imdbId,
    this.overview,
    this.releaseDate,
    this.homepage,
    this.genres,
    this.rating,
    this.backdropPath,
    this.posterPath,
    this.voteCount,
    this.progress,
    this.lastWatched,
    this.cast,
    this.crew,
    this.recommendations,
    this.videos
  });
}

class LocalizedTitleModel {

  final String iso_3166_1;
  final String title;
  final String type;

  LocalizedTitleModel({
    @required this.title,
    @required this.iso_3166_1,
    this.type
  });

  static LocalizedTitleModel fromJSON(Map json){
    return new LocalizedTitleModel(
      iso_3166_1: json['iso_3166_1'],
      title: json['title'],
      type: json['type']
    );
  }

}