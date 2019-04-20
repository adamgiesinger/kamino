import 'package:flutter/material.dart';

class BottomGradient extends StatelessWidget {
  // Positional offset.
  final double offset;
  final Color color;
  final double finalStop;

  BottomGradient({this.offset: 0.98, this.color: const Color(0xFF000000), this.finalStop: 0.1});
  BottomGradient.noOffset() : offset = 1.0, color = const Color(0xFF000000), this.finalStop = 0.1;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          gradient: (LinearGradient(
            end: FractionalOffset(0.0, 0.0),
            begin: FractionalOffset(0.0, offset),
            // Just a head's up:
            // Due to a slide cock-up, this is reversed
            // and nobody's bothered to change it yet.
            stops: [
              finalStop,
              0.35,
              0.9
            ],
            colors: <Color>[
              color.withOpacity(1),
              color.withOpacity(0),
              color.withOpacity(0.5)
            ],
          ))),
    );
  }
}