import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class Document {
  String signature = "PIXADOC";
  int width = 16;
  int height = 12;
  double pixelSize = 16.0;
  List<int> data = [];

  Color mainColor = Color.fromARGB(255, 0, 0xA0, 0xE3);

  bool drawGrid = true;
  double gridStokeWidth = 0.1;
  bool gridOffset = false;

  bool drawBorder = false;
  bool drawCenterLines = false;

  String typeOfItem = "roundSquare";
  double margin = 0.05;

  String path = "";

  Document() {
    init();
  }

  String mainColorAsString() {
    return mainColor.toARGB32().toRadixString(16);
  }

  void setMainColorFromString(String color) {
    mainColor = Color(int.parse(color, radix: 16));
  }

  void loadFromJsonFile(String path) {
    var file = File(path);
    var json = file.readAsStringSync();
    var success = loadFromJsonString(json);
    if (success) {
      this.path = path;
    }
  }

  void saveToJsonFile() {
    if (path.isEmpty) {
      return;
    }
    var file = File(path);
    var json = saveToJsonString();
    file.writeAsStringSync(json);
  }

  String saveToJsonString() {
    var map = {
      'signature': signature,
      'width': width,
      'height': height,
      'pixelSize': pixelSize,
      'data': data,
      'drawGrid': drawGrid,
      'gridStokeWidth': gridStokeWidth,
      'gridOffset': gridOffset,
      'mainColorHex': mainColorAsString(),
      'typeOfItem': typeOfItem,
      'margin': margin,
    };
    return jsonEncode(map);
  }

  bool loadFromJsonString(String json) {
    try {
      var map = jsonDecode(json);
      if (map['signature'] != signature) {
        return false;
      }

      signature = map['signature'];
      width = map['width'];
      height = map['height'];
      pixelSize = map['pixelSize'];
      data = List<int>.from(map['data']);
      drawGrid = map['drawGrid'];
      gridStokeWidth = map['gridStokeWidth'];
      gridOffset = map['gridOffset'];
      if (map['mainColorHex'] != null) {
        setMainColorFromString(map['mainColorHex']);
      }
      if (map['typeOfItem'] != null) {
        typeOfItem = map['typeOfItem'];
      }
      if (map['margin'] != null) {
        margin = map['margin'];
      }

      return true;
    } catch (e) {
      return false;
    }
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

  void draw(Canvas canvas, Size size, bool debug) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    double marginX = margin;
    double marginY = margin;
    double corner = 0.2;

    /*canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Color.fromARGB(255, 5, 5, 5),
    );*/

    if (drawGrid && gridStokeWidth > 0.001) {
      var gridPaint =
          Paint()
            ..color = mainColor
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

      if (drawCenterLines) {
        var widthOfPicture = width * pixelSize;
        var heightOfPicture = height * pixelSize;
        var paintOfDebugCenterLines =
            Paint()
              ..color = Colors.red
              ..strokeWidth = 0.5;
        canvas.drawLine(
          Offset(widthOfPicture / 2, 0),
          Offset(widthOfPicture / 2, heightOfPicture),
          paintOfDebugCenterLines,
        );

        canvas.drawLine(
          Offset(0, heightOfPicture / 2),
          Offset(widthOfPicture, heightOfPicture / 2),
          paintOfDebugCenterLines,
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
          c = mainColor;
          // c = Color.fromARGB(255, 200, 200, 200);
        }

        var marginXInPixel = pixelSize * marginX;
        var marginYInPixel = pixelSize * marginY;

        if (typeOfItem == "roundSquare") {
          canvas.drawRRect(
            RRect.fromRectXY(
              Rect.fromLTWH(
                posX + marginXInPixel,
                posY + marginYInPixel,
                pixelSize - marginXInPixel * 2,
                pixelSize - marginYInPixel * 2,
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

        if (typeOfItem == "square") {
          canvas.drawRect(
            Rect.fromLTWH(
              posX + marginXInPixel,
              posY + marginYInPixel,
              pixelSize - marginXInPixel * 2,
              pixelSize - marginYInPixel * 2,
            ),

            Paint()
              ..style = PaintingStyle.fill
              ..color = c
              ..strokeWidth = 0.5,
          );
        }

        if (typeOfItem == "circle") {
          canvas.drawOval(
            Rect.fromLTWH(
              posX + marginXInPixel,
              posY + marginYInPixel,
              pixelSize - marginXInPixel * 2,
              pixelSize - marginYInPixel * 2,
            ),
            Paint()
              ..style = PaintingStyle.fill
              ..color = c
              ..strokeWidth = 0.5,
          );
        }
      }
    }

    canvas.restore();
  }
}
