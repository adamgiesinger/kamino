import 'package:cplayer/cplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kamino/ui/uielements.dart';

class SourceSelectionView extends StatefulWidget {

  final String title;
  final List sourceList;

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

            return Material(
              color: Theme.of(context).backgroundColor,
              child: ListTile(
                enabled: true,
                isThreeLine: true,

                title: TitleText("${source["metadata"]["provider"]} • ${source["metadata"]["ping"]}ms"),
                subtitle: Text(
                    source["file"]["data"],
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
                              url: source["file"]["data"],
                              mimeType: 'video/mp4'
                          ))
                  );
                },
                onLongPress: (){
                  Clipboard.setData(new ClipboardData(text: source["file"]["data"]));
                  Scaffold.of(ctx).showSnackBar(new SnackBar(
                    content: new TitleText("URL Copied!"),
                    backgroundColor: Theme.of(context).primaryColor
                  ));
                },
              ),
            );
          })
      )
    );
  }

}