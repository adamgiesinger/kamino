import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';

class ApolloLoadingSpinner extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 48,
      child: FlareActor(
        "lib/res/loader.flr",
        alignment: Alignment.center,
        fit: BoxFit.fill,
        animation: "loading",
        controller: new ApolloLoadingSpinnerController(context),
      ),
    );
  }

}

class ApolloLoadingSpinnerController extends FlareController {

  final BuildContext context;
  ApolloLoadingSpinnerController(BuildContext context) : this.context = context;

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    artboard.nodes.where((ActorNode node) => node is FlutterActorShape)
        .forEach((ActorNode node) => (node as FlutterActorShape).strokes
          .where((stroke) => stroke is FlutterColorStroke).cast<FlutterColorStroke>()
            .forEach((FlutterColorStroke stroke){
              Color primaryColor = Theme.of(context).primaryColor;

              switch(node.name){
                case "Light":
                  stroke.uiColor = primaryColor;
                  break;
                case "Middle":
                  Color middleColor = primaryColor
                      .withRed((primaryColor.red * 0.8).round())
                      .withGreen((primaryColor.green * 0.8).round())
                      .withBlue((primaryColor.blue * 0.8).round());

                  stroke.uiColor = middleColor;
                  break;
                case "Dark":
                  Color darkenedColor = primaryColor
                        .withRed((primaryColor.red * 0.6).round())
                        .withGreen((primaryColor.green * 0.6).round())
                        .withBlue((primaryColor.blue * 0.6).round())
                        .withOpacity(0.8);

                  stroke.uiColor = darkenedColor;
                  break;
              }

          })
    );
    // TODO: implement initialize
  }

  @override
  void setViewTransform(Mat2D viewTransform) {
    // TODO: implement setViewTransform
  }

}