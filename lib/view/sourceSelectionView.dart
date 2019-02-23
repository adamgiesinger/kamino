import 'package:cplayer/cplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino/ui/uielements.dart';
import "package:kamino/models/SourceModel.dart";
import 'package:kamino/util/interface.dart';

class SourceSelectionView extends StatefulWidget {

  final String title;
  final List<SourceModel> sourceList;

  @override
  State<StatefulWidget> createState() => SourceSelectionViewState();

  SourceSelectionView({
    @required this.title,
    @required this.sourceList
  });

}

class SourceSelectionViewState extends State<SourceSelectionView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: TitleText(
            widget.title
        ),
        centerTitle: true,
      ),
      body: Container(
        child: ListView.builder(
          itemCount: widget.sourceList.length,
          itemBuilder: (BuildContext ctx, int index){
            var source = widget.sourceList[index];

            print(source);

            String qualityInfo = "-"; // until we sort out quality detection
            if(source.metadata.quality != null)
              qualityInfo = source.metadata.quality;

            /*
            if(source["metadata"]["extended"] != null){
              var extendedMeta = source["metadata"]["extended"]["streams"][0];
              var resolution = extendedMeta["coded_height"];

              if(resolution < 360) qualityInfo = "[LQ]";
              if(resolution >= 360) qualityInfo = "[SD]";
              if(resolution > 720) qualityInfo = "[HD]";
              if(resolution > 1080) qualityInfo = "[FHD]";
              if(resolution > 2160) qualityInfo = "[4K]";

              qualityInfo += " [" + extendedMeta["codec_name"].toUpperCase() + "]";
            }
              */

            return Material(
              color: Theme.of(context).backgroundColor,
              child: ListTile(
                enabled: true,
                isThreeLine: true,

                title: TitleText((qualityInfo != null ? qualityInfo + " • " : "") + "${source.metadata.source} (${source.metadata.provider}) • ${source.metadata.ping}ms"),
                subtitle: Text(
                    source.file.data,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: Icon(Icons.insert_drive_file),

                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          CPlayer(
                              title: widget.title,
                              url: source.file.data,
                              mimeType: 'video/mp4'
                          ))
                  );
                },
                onLongPress: (){
                  Clipboard.setData(new ClipboardData(text: source.file.data));
                  Interface.showSnackbar("URL copied!");
                },
              ),
            );
          })
      )
    );
  }

}