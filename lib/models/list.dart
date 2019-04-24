import 'package:kamino/models/content.dart';
import 'package:kamino/models/movie.dart';
import 'package:kamino/models/tv_show.dart';
import 'package:meta/meta.dart';

class ContentListModel {

  final int id;
  String name;
  String backdrop;
  String poster;
  String description;
  String creatorName;
  bool public;
  List<ContentModel> content;

  bool fullyLoaded;
  int totalPages;

  ContentListModel({
    @required this.id,
    this.name,
    this.backdrop,
    this.poster,
    this.description,
    this.creatorName,
    this.public,
    this.content,
    @required this.fullyLoaded,
    @required this.totalPages
  });

  static ContentListModel fromJSON(Map json){
    return new ContentListModel(
      id: json["id"],
      name: json["name"],
      backdrop: json["backdrop_path"],
      poster: json["poster_path"],
      description: json["description"],
      creatorName: json["created_by"]["name"],
      public: json["public"],
      content: (json["results"] as List).map((entry) => entry["media_type"] == "movie"
          ? MovieContentModel.fromJSON(entry)
          : TVShowContentModel.fromJSON(entry)).toList(),
      totalPages: json["total_pages"],
      fullyLoaded: json["total_pages"] <= 1 ? true : false
    );
  }

}