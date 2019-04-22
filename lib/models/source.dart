class SourceModel {

  final SourceFile file;
  final bool isResultOfScrape;
  final SourceMetadata metadata;

  bool operator ==(o) => o is SourceModel && o.file.data == file.data; // if URL is the same, we can say it's the same thing
  int get hashCode => file.data.hashCode;

  SourceModel.fromJSON(Map json)
      : file = SourceFile.fromJSON(json["file"]),
        isResultOfScrape = json["isResultOfScrape"],
        metadata = SourceMetadata.fromJSON(json["metadata"]);

  SourceModel.fromRDJSON(Map json)
      : file = SourceFile.fromRDJSON(json),
        isResultOfScrape = true,
        metadata = SourceMetadata.fromRDJSON(json);
}

class SourceFile {
  final String data;
  final String kind;

  SourceFile.fromJSON(Map json)
      : data = json["data"],
        kind = json["kind"];

  SourceFile.fromRDJSON(Map json)
      : data = json["download"],
        kind = json["mimeType"];
}

class SourceMetadata {
  final String cookie;
  final bool isStreamable;
  String provider;
  String quality;
  String source;
  final int ping;
  int contentLength;

  SourceMetadata.fromJSON(Map json)
      : cookie = json["cookie"],
        isStreamable = json["isStreamable"],
        provider = json["provider"] != null ? json["provider"] : "Unknown",
        quality = json["quality"] != null ? json["quality"] : null,
        source = json["source"] != null ? json["source"] : "Unknown",
        ping = json["ping"];

  SourceMetadata.fromRDJSON(Map json)
      : cookie = "",
        isStreamable = json["streamable"] != null && json["streamable"]  == 1 ? true : false,
        provider = json["provider"] != null ? json["provider"] : "Unknown",
        quality = json["quality"] != null ? json["quality"] : null,
        source = json["source"] != null ? json["source"] : "Unknown",
        contentLength = json["filesize"] != null ? json["filesize"] : "0",
        ping = 0;
}
