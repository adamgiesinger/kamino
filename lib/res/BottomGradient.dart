import 'package:flutter/material.dart';

class BottomGradient extends StatelessWidget {
  // Positional offset.
  final double offset;
  final Color color;

  BottomGradient({this.offset: 0.98, this.color: const Color(0xFF000000)});
  BottomGradient.noOffset() : offset = 1.0, color = const Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            end: FractionalOffset(0.0, 0.0),
            begin: FractionalOffset(0.0, offset),
            stops: [
              0.1,
              0.35,
              0.9
            ],
            colors: <Color>[
              color.withOpacity(1),
              color.withOpacity(0),
              color.withOpacity(0)
            ],
          )),
    );
  }
}