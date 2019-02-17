class SourceModel {

  final SourceFile file;
  final bool isResultOfScrape;
  final SourceMetadata metadata;

  SourceModel.fromJSON(Map json)
      : file = SourceFile.fromJSON(json["file"]),
        isResultOfScrape = json["isResultOfScrape"],
        metadata = SourceMetadata.fromJSON(json["metadata"]);
}

class SourceFile {
  final String data;
  final String kind;

  SourceFile.fromJSON(Map json)
    : data = json["data"],
      kind = json["kind"];
}

class SourceMetadata {
  final String cookie;
  final bool isDownload;
  final String provider;
  final String quality;
  final String source;
  final int ping;

  SourceMetadata.fromJSON(Map json)
    : cookie = json["cookie"],
      isDownload = json["isDownload"],
      provider = json["provider"],
      quality = json["quality"],
      source = json["source"],
      ping = json["ping"];
}