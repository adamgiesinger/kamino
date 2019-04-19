import 'package:kamino/models/content.dart';
import 'package:kamino/models/crew.dart';
import 'package:meta/meta.dart';

class MovieContentModel extends ContentModel {

  //final List reviews;
  final String imdbId;
  final double runtime;

  MovieContentModel({
    // Content model inherited parameters
    @required int id,
    @required String title,
    String overview,
    String releaseDate,
    String homepage,
    List genres,
    double rating,
    String backdropPath,
    String posterPath,
    int voteCount,
    List cast,
    List crew,
    List<MovieContentModel> similar,
    List videos,

    // Movie parameters
    //this.reviews,
    //this.recommendations,
    this.imdbId,
    this.runtime
  }) : super( // Call the parent constructor...
    id: id,
    title: title,
    contentType: ContentType.MOVIE,
    overview: overview,
    releaseDate: releaseDate,
    homepage: homepage,
    genres: genres,
    rating: rating,
    backdropPath: backdropPath,
    posterPath: posterPath,
    voteCount: voteCount,
    cast: cast,
    crew: crew,
    similar: similar,
    videos: videos
  );

  static MovieContentModel fromJSON(Map json){
    Map credits = json['credits'] != null ? json['credits'] : {'cast': null, 'crew': null};
    List videos = json['videos'] != null ? json['videos']['results'] : null;
    List<MovieContentModel> similar = json['similar'] != null
      ? (json['similar']['results'] as List).map(
          (element) => MovieContentModel.fromJSON(element)
        ).toList()
      : null;

    return new MovieContentModel(
      // Inherited properties.
      // (Copy-paste these to other models.)
      id: json["id"],
      title: json["title"],
      overview: json["overview"],
      releaseDate: json["release_date"],
      homepage: json["homepage"],
      genres: json["genres"],
      rating: json["vote_average"] != null ? json["vote_average"].toDouble() : -1.0,
      backdropPath: json["backdrop_path"],
      posterPath: json["poster_path"],
      voteCount: json.containsKey("vote_count") ? json["vote_count"] : 0,

      // Object-specific properties.
      imdbId: json["imdb_id"],
      runtime: json["runtime"] != null ? json["runtime"].toDouble() : null,
      cast: credits['cast'] != null ? (credits['cast'] as List).map((entry) => CastMemberModel.fromJSON(entry)).toList() : null,
      crew: credits['crew'] != null ? (credits['crew'] as List).map((entry) => CrewMemberModel.fromJSON(entry)).toList() : null,
      similar: similar,
      videos: videos
    );
  }
}
