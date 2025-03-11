import 'package:flutter/material.dart';
import 'package:pixa/doc/doc.dart';

class DocPainter extends CustomPainter {
  final Document _doc;
  DocPainter(this._doc);

  @override
  void paint(Canvas canvas, Size size) {
    _doc.draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

