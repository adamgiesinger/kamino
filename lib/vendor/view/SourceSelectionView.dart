import 'package:cplayer/cplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/ui/ui_elements.dart';
import "package:kamino/models/source.dart";
import 'package:kamino/util/interface.dart';
import 'package:kamino/vendor/struct/ClawsVendorConfiguration.dart';

class SourceSelectionView extends StatefulWidget {

  static const double _kAppBarProgressHeight = 4.0;

  final String title;
  final ClawsVendorDelegate delegate;

  @override
  State<StatefulWidget> createState() => SourceSelectionViewState();

  SourceSelectionView({
    @required this.title,
    @required this.delegate
  });

}

class SourceSelectionViewState extends State<SourceSelectionView> {

  @override
  void initState() {
    widget.delegate.addSourceEvent((discoveredSource){ if(mounted) setState((){}); });
    widget.delegate.addCloseEvent((){ if(mounted) setState((){}); });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<SourceModel> sourceList = new List();
    widget.delegate.sourceList.forEach((model){
      // If sourceList does not contain a SourceModel with model's URL
      if(sourceList.where((_searchModel) => _searchModel.file.data == model.file.data).length == 0){
        sourceList.add(model);
      }
    });

    _sortList(sourceList);

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: TitleText(
            "${widget.title} \u2022 ${sourceList.length} sources"
        ),
        centerTitle: true,
        bottom: PreferredSize(
          child: (widget.delegate != null && !widget.delegate.inClosedState) ? SizedBox(
            height: SourceSelectionView._kAppBarProgressHeight,
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor
              ),
            ),
          ) : Container(),
          preferredSize: Size(double.infinity, SourceSelectionView._kAppBarProgressHeight)
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: sourceList.length,
          itemBuilder: (BuildContext ctx, int index){
            var source = sourceList[index];

            String qualityInfo; // until we sort out quality detection
            if(source.metadata.quality != null
                && source.metadata.quality.replaceAll(" ", "").isNotEmpty)
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
                  Interface.showSnackbar(S.of(context).url_copied);
                },
              ),
            );

          })
      )
    );
  }

  _sortList(List<SourceModel> sourceList) {
    sourceList.sort((SourceModel left, SourceModel right) {
      return left.metadata.ping.compareTo(right.metadata.ping);
    });
  }

}