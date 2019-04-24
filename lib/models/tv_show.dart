import 'package:kamino/models/content.dart';
import 'package:kamino/models/crew.dart';
import 'package:meta/meta.dart';

class TVShowContentModel extends ContentModel {

  final List createdBy;
  final List episodeRuntime;
  final List seasons;
  final List networks;
  final String status;
  final double popularity;

  TVShowContentModel({
    // Content model inherited parameters
    @required int id,
    @required String title,
    List<LocalizedTitleModel> alternativeTitles,
    String originalTitle,
    String originalCountry,
    String imdbId,
    String overview,
    String releaseDate,
    String homepage,
    List genres,
    List reviews,
    List recommendations,
    double rating,
    String backdropPath,
    String posterPath,
    int voteCount,
    double voteAverage,
    double progress,
    String lastWatched,
    List cast,
    List crew,
    List<TVShowContentModel> similar,
    List videos,

    // TV Show parameters
    this.createdBy,
    this.episodeRuntime,
    this.seasons,
    this.networks,
    this.status,
    this.popularity
  }) : super( // Call the parent constructor...
    id: id,
    imdbId: imdbId,
    title: title,
    alternativeTitles: alternativeTitles,
    contentType: ContentType.TV_SHOW,
    overview: overview,
    releaseDate: releaseDate,
    homepage: homepage,
    genres: genres,
    rating: rating,
    backdropPath: backdropPath,
    posterPath: posterPath,
    voteCount: voteCount,
    progress: progress,
    lastWatched: lastWatched,
    cast: cast,
    crew: crew,
    similar: similar,
    videos: videos,
    originalTitle: originalTitle,
    originalCountry: originalCountry
  );

  static TVShowContentModel fromJSON(Map json){
    Map credits = json['credits'] != null ? json['credits'] : {'cast': null, 'crew': null};
    List videos = json['videos'] != null ? json['videos']['results'] : null;
    List<TVShowContentModel> similar = json['similar'] != null
        ? (json['similar']['results'] as List).map(
            (element) => TVShowContentModel.fromJSON(element)
    ).toList()
        : null;
    List<LocalizedTitleModel> alternativeTitles = json['alternative_titles'] != null
      ? (json['alternative_titles']['results'] as List).map(
        (element) => LocalizedTitleModel.fromJSON(element)
    ).toList() : null;

    return new TVShowContentModel(
      // Inherited properties.
      // (Copy-paste these to other models - it is fine to make small changes.)
      id: json["id"],
      imdbId: json["external_ids"] != null ? json["external_ids"]["imdb_id"] : null,
      title: json["name"] == null ? json["original_name"] : json["name"],
      overview: json["overview"],
      releaseDate: json["first_air_date"],
      homepage: json["homepage"],
      genres: json["genres"],
      rating: json["vote_average"] != null ? json["vote_average"] : -1,
      backdropPath: json["backdrop_path"],
      posterPath: json["poster_path"],
      voteCount: json["vote_count"] != null ? json["vote_count"] : 0,
      cast: credits['cast'] != null ? (credits['cast'] as List).map((entry) => CastMemberModel.fromJSON(entry)).toList() : null,
      crew: credits['crew'] != null ? (credits['crew'] as List).map((entry) => CrewMemberModel.fromJSON(entry)).toList() : null,
      similar: similar,
      videos: videos,
      alternativeTitles: alternativeTitles,
      originalCountry: json['origin_country'] != null && json['origin_country'].length > 0
          ? json['origin_country'][0] : null,
      originalTitle: json['original_name'],

      // Object-specific properties.
      createdBy: json["created_by"],
      episodeRuntime: json["episode_run_time"],
      seasons: json["seasons"],
      networks: json["networks"],
      status: json["status"],
      popularity: json["popularity"],
    );
  }

}
