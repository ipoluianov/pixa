import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class Document {

  int width = 16;
  int height = 12;
  double pixelSize = 16.0;
  List<int> data = [];

  bool drawGrid = true;
  double gridStokeWidth = 0.1;
  bool gridOffset = false;

  bool drawBorder = false;

  Document() {
    init();
  }

  void init() {
    int count = width * height;
    data.clear();
    for (int i = 0; i < count; i++) {
      data.add(0);
    }
  }

  void setPixel(int x, int y) {
    var pos = y * width + x;
    if (pos < data.length) {
      if (data[pos] != 0) {
        data[pos] = 0;
      } else {
        data[pos] = 1;
      }
    }
  }

  int getPixel(int x, int y) {
    var pos = y * width + x;
    if (pos >= data.length) {
      return 0;
    }
    var d = data[pos];
    if (d != 0) {
      return d;
    }
    return d;
  }

  void draw(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    double marginX = 0.05;
    double marginY = 0.05;
    double corner = 0.2;

    /*canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Color.fromARGB(255, 5, 5, 5),
    );*/

    if (drawGrid) {
      var gridPaint =
          Paint()
            ..color = Color.fromARGB(255, 0, 0xA0, 0xE3)
            ..strokeWidth = gridStokeWidth;
      // Draw grid
      var grOffsetX = gridOffset ? pixelSize / 2.0 : 0.0;
      var grOffsetY = gridOffset ? pixelSize / 2.0 : 0.0;
      var maxX = width;
      if (!gridOffset) {
        maxX += 1;
      }
      for (int x = 0; x < maxX; x++) {
        var pX = x * pixelSize;
        canvas.drawLine(
          Offset(pX + grOffsetX, grOffsetY),
          Offset(pX + grOffsetX, height * pixelSize - grOffsetY),
          gridPaint,
        );
      }
      var maxY = height;
      if (!gridOffset) {
        maxY += 1;
      }
      for (int y = 0; y < maxY; y++) {
        var pY = y * pixelSize;
        canvas.drawLine(
          Offset(grOffsetX, pY + grOffsetY),
          Offset(width * pixelSize - grOffsetX, pY + grOffsetY),
          gridPaint,
        );
      }
    }

    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        double posX = x * pixelSize;
        double posY = y * pixelSize;
        Color c = Colors.transparent;
        int pixelData = getPixel(x, y);
        if (pixelData > 0) {
          c = Color.fromARGB(255, 0, 0xA0, 0xE3);
          // c = Color.fromARGB(255, 200, 200, 200);
        }

        /*if (doc.drawGrid) {
          var grOffsetX = doc.gridOffset ? doc.pixelSize / 2 : 0;
          var grOffsetY = doc.gridOffset ? doc.pixelSize / 2 : 0;

          canvas.drawRect(
            Rect.fromLTWH(
              posX + grOffsetX,
              posY + grOffsetY,
              doc.pixelSize,
              doc.pixelSize,
            ),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = Color.fromARGB(255, 0, 0xA0, 0xE3)
              ..strokeWidth = gridStokeWidth,
          );
        }*/

        /*canvas.drawRect(
          Rect.fromLTWH(posX, posY, pixelSize, pixelSize),
          Paint()
            ..style = PaintingStyle.fill
            ..color = c,
        );*/

        canvas.drawRRect(
          RRect.fromRectXY(
            Rect.fromLTWH(
              posX + pixelSize * marginX,
              posY + pixelSize * marginY,
              pixelSize * 0.9 - pixelSize * marginX * 2,
              pixelSize * 0.9 - pixelSize * marginY * 2,
            ),
            pixelSize * corner,
            pixelSize * corner,
          ),
          Paint()
            ..style = PaintingStyle.fill
            ..color = c
            ..strokeWidth = 0.5,
        );
      }
    }

    canvas.restore();
  }
}
