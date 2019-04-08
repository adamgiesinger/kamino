import 'package:cplayer/cplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino/generated/i18n.dart';
import 'package:kamino/ui/elements.dart';
import "package:kamino/models/source.dart";
import 'package:kamino/ui/interface.dart';
import 'package:kamino/vendor/struct/VendorService.dart';

class SourceSelectionView extends StatefulWidget {

  static const double _kAppBarProgressHeight = 4.0;

  final String title;
  final VendorService service;

  @override
  State<StatefulWidget> createState() => SourceSelectionViewState();

  SourceSelectionView({
    @required this.title,
    @required this.service
  });

}

class SourceSelectionViewState extends State<SourceSelectionView> {

  List<SourceModel> sourceList = new List();

  String sortingMethod = 'ping';
  bool sortReversed = false;

  @override
  void initState() {
    widget.service.addUpdateEvent(() {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  Future<bool> _handlePop() async {
    widget.service.setStatus(context, VendorServiceStatus.IDLE);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    widget.service.sourceList.forEach((model) {
      // If sourceList does not contain a SourceModel with model's URL
      if (sourceList
          .where((_searchModel) => _searchModel.file.data == model.file.data)
          .length == 0) {
        sourceList.add(model);
      }
    });

    _sortList();

    return WillPopScope(
      onWillPop: _handlePop,
      child: Scaffold(
          backgroundColor: Theme
              .of(context)
              .backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme
                .of(context)
                .backgroundColor,
            title: TitleText(
                "${widget.title} \u2022 ${sourceList.length} sources"
            ),
            centerTitle: true,
            bottom: PreferredSize(
                child: (widget.service.status != VendorServiceStatus.DONE)
                    ? SizedBox(
                  height: SourceSelectionView._kAppBarProgressHeight,
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme
                            .of(context)
                            .primaryColor
                    ),
                  ),
                )
                    : Container(),
                preferredSize: Size(
                    double.infinity, SourceSelectionView._kAppBarProgressHeight)
            ),
            actions: <Widget>[
              IconButton(icon: Icon(Icons.sort), onPressed: () => _showSortingDialog(context))
            ],
          ),
          body: Container(
              child: ListView.builder(
                  itemCount: sourceList.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    var source = sourceList[index];

                    String qualityInfo; // until we sort out quality detection
                    if (source.metadata.quality != null
                        && source.metadata.quality
                            .replaceAll(" ", "")
                            .isNotEmpty)
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
                      color: Theme
                          .of(context)
                          .backgroundColor,
                      child: ListTile(
                        enabled: true,
                        isThreeLine: true,

                        title: TitleText(
                            (qualityInfo != null ? qualityInfo + " • " : "") +
                                "${source.metadata.source} (${source.metadata
                                    .provider}) • ${source.metadata.ping}ms"),
                        subtitle: Text(
                          source.file.data,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Icon(Icons.insert_drive_file),

                        onTap: () {
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
                        onLongPress: () {
                          Clipboard.setData(
                              new ClipboardData(text: source.file.data));
                          Interface.showSnackbar(S
                              .of(context)
                              .url_copied, context: ctx);
                        },
                      ),
                    );
                  })
          )
      ),
    );
  }

  _sortList() {
    /* By default, sorting is descending. (Ideally best to worst.)
     * Reversed, is descending. */

    sourceList.sort((SourceModel left, SourceModel right) {
      if(sortingMethod == 'quality'){
        return _getSourceQualityIndex(left.metadata.quality).compareTo(_getSourceQualityIndex(right.metadata.quality));
      }else if(sortingMethod == 'name'){
        return left.metadata.source.compareTo(right.metadata.source);
      }

      return left.metadata.ping.compareTo(right.metadata.ping);
    });

    if(this.sortReversed) sourceList = sourceList.reversed.toList();
    if(mounted) setState(() {});
  }

  _showSortingDialog(BuildContext context) async {
    var sortingSettings = (await showDialog(context: context, builder: (BuildContext context){
      return SourceSortingDialog(sortingMethod: sortingMethod, sortReversed: sortReversed);
    }));

    if(sortingSettings != null) {
      this.sortingMethod = sortingSettings[0];
      this.sortReversed = sortingSettings[1];

      _sortList();
    }
  }

  int _getSourceQualityIndex(String quality){
    switch(quality){
      case 'CAM': return 0;
      case 'SCR': return 10;
      case 'HQ': return 20;
      case '360p': return 30;
      case '480p': return 40;
      case '720p': return 50;
      case '1080p': return 60;
      case '4K': return 70;
      default: return -1;
    }
  }

}

class SourceSortingDialog extends StatefulWidget {

  final String sortingMethod;
  final bool sortReversed;

  SourceSortingDialog({
    @required this.sortingMethod,
    @required this.sortReversed
  });

  @override
  State<StatefulWidget> createState() => SourceSortingDialogState();

}

class SourceSortingDialogState extends State<SourceSortingDialog> {

  String sortingMethod;
  bool sortReversed;

  @override
  void initState() {
    sortingMethod = widget.sortingMethod;
    sortReversed = widget.sortReversed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10).copyWith(top: 20),
      title: TitleText("Sort By..."),
      children: <Widget>[

        Column(
          children: <Widget>[
            RadioListTile(
              isThreeLine: true,
              secondary: Icon(Icons.network_check),
              title: Text('Ping'),
              subtitle: Text('Sorts by the time the server took to respond.'),
              value: 'ping',
              groupValue: sortingMethod,
              onChanged: (value){
                setState(() {
                  sortingMethod = value;
                });
              },
              activeColor: Theme.of(context).primaryColor,
              controlAffinity: ListTileControlAffinity.trailing,
            ),

            RadioListTile(
              secondary: Icon(Icons.high_quality),
              title: Text('Quality'),
              subtitle: Text('Sorts by source quality.'),
              value: 'quality',
              groupValue: sortingMethod,
              onChanged: (value){
                setState(() {
                  sortingMethod = value;
                });
              },
              activeColor: Theme.of(context).primaryColor,
              controlAffinity: ListTileControlAffinity.trailing,
            ),

            RadioListTile(
              secondary: Icon(Icons.sort_by_alpha),
              title: Text('Name'),
              subtitle: Text('Sorts alphabetically by name.'),
              value: 'name',
              groupValue: sortingMethod,
              onChanged: (value){
                setState(() {
                  sortingMethod = value;
                });
              },
              activeColor: Theme.of(context).primaryColor,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          ],
        ),

        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton.icon(
                  color: !sortReversed ? Theme.of(context).primaryColor : null,
                  onPressed: () async {
                    sortReversed = false;
                    setState(() {});
                  },
                  icon: Icon(Icons.keyboard_arrow_up),
                  label: TitleText("Ascending")
              ),
              FlatButton.icon(
                  color: sortReversed ? Theme.of(context).primaryColor : null,
                  onPressed: () async {
                    sortReversed = true;
                    setState(() {});
                  },
                  icon: Icon(Icons.keyboard_arrow_down),
                  label: TitleText("Descending")
              )
            ],
          ),
        ),

        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new FlatButton(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
                textColor: Theme.of(context).primaryColor,
              ),

              new FlatButton(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: (){
                  Navigator.of(context).pop([sortingMethod, sortReversed]);
                },
                child: Text("Done"),
                textColor: Theme.of(context).primaryColor,
              )
            ],
          ),
        )
      ],
    );
  }

}