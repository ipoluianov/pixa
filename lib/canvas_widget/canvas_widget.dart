import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return CanvasWidgetState();
  }
}

class Document {
  int width = 16;
  int height = 12;
  double pixelSize = 16.0;
  List<int> data = [];

  bool drawGrid = true;
  double gridStokeWidth = 0.05;
  bool gridOffset = false;

  bool drawBorder = false;

  Document() {
    init();

    setPixel(5, 5);
  }

  void init() {
    int count = width * height;
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

  void saveToPng() async {
    var recorder = ui.PictureRecorder();
    var canvas = Canvas(
      recorder,
      Rect.fromLTWH(0.0, 0.0, width * pixelSize, height * pixelSize),
    );
    var painter = MapPainter();
    painter.paint(canvas, Size(width * pixelSize, height * pixelSize));
    var pic = recorder.endRecording();
    var image = await pic.toImage(
      (width * pixelSize).round(),
      (height * pixelSize).round(),
    );
    var bs = await image.toByteData(format: ui.ImageByteFormat.png);
    var bytes = bs!.buffer.asUint8List();
    var file = File('test.png');
    file.writeAsBytesSync(bytes);
    print('Saved to test.png');
  }

  void draw(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    double marginX = 0.05;
    double marginY = 0.05;
    double corner = 0.2;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Color.fromARGB(255, 5, 5, 5),
    );

    if (drawGrid) {
      var gridPaint =
          Paint()
            ..color = Color.fromARGB(255, 0, 0xA0, 0xE3)
            ..strokeWidth = gridStokeWidth;
      // Draw grid
      var grOffsetX = doc.gridOffset ? doc.pixelSize / 2.0 : 0.0;
      var grOffsetY = doc.gridOffset ? doc.pixelSize / 2.0 : 0.0;
      var maxX = doc.width;
      if (!doc.gridOffset) {
        maxX += 1;
      }
      for (int x = 0; x < maxX; x++) {
        var pX = x * doc.pixelSize;
        canvas.drawLine(
          Offset(pX + grOffsetX, grOffsetY),
          Offset(pX + grOffsetX, height * pixelSize - grOffsetY),
          gridPaint,
        );
      }
      var maxY = doc.height;
      if (!doc.gridOffset) {
        maxY += 1;
      }
      for (int y = 0; y < maxY; y++) {
        var pY = y * doc.pixelSize;
        canvas.drawLine(
          Offset(grOffsetX, pY + grOffsetY),
          Offset(width * pixelSize - grOffsetX, pY + grOffsetY),
          gridPaint,
        );
      }
    }

    for (int x = 0; x < doc.width; x++) {
      for (int y = 0; y < doc.height; y++) {
        double posX = x * doc.pixelSize;
        double posY = y * doc.pixelSize;
        Color c = Colors.transparent;
        int pixelData = doc.getPixel(x, y);
        if (pixelData > 0) {
          c = Color.fromARGB(255, 0, 0xA0, 0xE3);
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
              posX + doc.pixelSize * marginX,
              posY + doc.pixelSize * marginY,
              doc.pixelSize * 0.9 - doc.pixelSize * marginX * 2,
              doc.pixelSize * 0.9 - doc.pixelSize * marginY * 2,
            ),
            doc.pixelSize * corner,
            doc.pixelSize * corner,
          ),
          Paint()
            ..style = PaintingStyle.fill
            ..color = c,
        );
      }
    }

    canvas.restore();
  }
}

Document doc = Document();

class MapPainter extends CustomPainter {
  MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    doc.draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CanvasWidgetState extends State<CanvasWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Listener(
            onPointerDown: (event) {
              int x = (event.localPosition.dx / doc.pixelSize - 0.5).round();
              int y = (event.localPosition.dy / doc.pixelSize - 0.5).round();
              setState(() {
                doc.setPixel(x, y);
              });
              print(
                "Click: ${event.localPosition.dx} ${event.localPosition.dy}",
              );
              print("Click: $x $y");
            },
            child: CustomPaint(
              painter: MapPainter(),
              child: Container(),
              key: UniqueKey(),
            ),
          ),
        ),
        SizedBox(
          width: 300,
          child: Column(
            children: [
              Text('Tools'),
              ElevatedButton(
                onPressed: () {
                  doc.saveToPng();
                },
                child: Text('Save'),
              ),
              Row(
                children: [
                  Text('Grid'),
                  Checkbox(
                    value: doc.drawGrid,
                    onChanged: (v) {
                      setState(() {
                        doc.drawGrid = v!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Grid Offset'),
                  Checkbox(
                    value: doc.gridOffset,
                    onChanged: (v) {
                      setState(() {
                        doc.gridOffset = v!;
                      });
                    },
                  ),
                ],
              ),
              Slider(
                value: doc.gridStokeWidth,
                onChanged: (v) {
                  setState(() {
                    doc.gridStokeWidth = v;
                  });
                },
                min: 0,
                max: 1,
              ),
              Row(children: [
                Text('PixelSize'),
                Slider(
                  value: doc.pixelSize,
                  onChanged: (v) {
                    setState(() {
                      doc.pixelSize = v;
                    });
                  },
                  min: 1,
                  max: 100,
                ),
              ],)
            ],
          ),
        ),
      ],
    );
  }
}
