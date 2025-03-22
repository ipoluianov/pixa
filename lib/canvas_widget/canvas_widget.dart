import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pixa/doc/png_saver.dart';
import 'package:pixa/files_widget/files_widget.dart';

import '../doc/doc.dart';
import '../doc/doc_painter.dart';

class CanvasWidget extends StatefulWidget {
  const CanvasWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return CanvasWidgetState();
  }
}

Document doc = Document();

class CanvasWidgetState extends State<CanvasWidget> {
  double _scale = 1;
  String _originalContent = "";

  Widget buildSetSizeButton(int size) {
    bool isCurrent = (doc.pixelSize - size.toDouble()).abs() < 0.1;
    Color color = isCurrent ? Colors.cyan : Colors.white;
    return Row(
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              doc.pixelSize = size.toDouble();
            });
          },
          child: Text("$size", style: TextStyle(color: color)),
        ),
      ],
    );
  }

  void applyStyleToAll() {
    String path = doc.path;
    String parentPath = File(path).parent.path;
    Directory dir = Directory(parentPath);
    List<FileSystemEntity> files = dir.listSync();
    for (FileSystemEntity file in files) {
      if (file is File) {
        if (file.path.endsWith(".pixa")) {
          Document d = Document();
          d.loadFromJsonFile(file.path);
          d.mainColor = doc.mainColor;
          d.drawGrid = doc.drawGrid;
          d.gridStokeWidth = doc.gridStokeWidth;
          d.gridOffset = doc.gridOffset;
          d.drawBorder = doc.drawBorder;
          d.typeOfItem = doc.typeOfItem;
          d.margin = doc.margin;
          d.pixelSize = doc.pixelSize;
          d.saveToJsonFile();
        }
      }
    }
  }

  void loadDocument(String path) {
    doc = Document();
    doc.loadFromJsonFile(path);
    _originalContent = doc.saveToJsonString();
    setState(() {});
  }

  Widget buildColorButton(Color color) {
    bool isCurrent = doc.mainColor == color;
    Color borderColor = isCurrent ? Colors.cyan : Colors.transparent;

    return TextButton(
      onPressed: () {
        doc.setMainColorFromString(color.toARGB32().toRadixString(16));
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 3),
        ),
        child: Container(
          width: 20,
          height: 20,
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(5),
          color: color,
        ),
      ),
    );
  }

  Widget buildGridLinesWidthButton(double width) {
    bool isCurrent = (doc.gridStokeWidth - width).abs() < 0.01;
    Color color = isCurrent ? Colors.cyan : Colors.white;
    return TextButton(
      onPressed: () {
        doc.gridStokeWidth = width;
        setState(() {});
      },
      child: Text(width.toString(), style: TextStyle(color: color)),
    );
  }

  Widget buildItemTypeButton(String type) {
    bool isCurrent = doc.typeOfItem == type;
    Color color = isCurrent ? Colors.cyan : Colors.white;
    return TextButton(
      onPressed: () {
        doc.typeOfItem = type;
        setState(() {});
      },
      child: Text(type, style: TextStyle(color: color)),
    );
  }

  Widget buildMarginButton(double margin) {
    bool isCurrent = (doc.margin - margin).abs() < 0.01;
    Color color = isCurrent ? Colors.cyan : Colors.white;
    return TextButton(
      onPressed: () {
        doc.margin = margin;
        setState(() {});
      },
      child: Text(margin.toString(), style: TextStyle(color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool changed = _originalContent != doc.saveToJsonString();
    Color colorOfSaveButton = changed ? Colors.red : Colors.black;

    return Row(
      children: [
        FilesWidget((path) {
          print("Selected file: $path");
          loadDocument(path);
        }),
        Expanded(
          child: Container(
            color: Colors.black,
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
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  setState(() {
                    _scale = (_scale - event.scrollDelta.dy * 0.001).clamp(
                      0.5,
                      3.0,
                    );
                  });
                  print("Scale: $_scale");
                  //doc.pixelSize = 16 * _scale;
                  // doc._scale = _scale;
                }
              },
              child: CustomPaint(
                painter: DocPainter(doc),
                child: Container(),
                key: UniqueKey(),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          width: 500,
          child: Column(
            children: [
              Text('Tools'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    var path = doc.path;
                    doc = Document();
                    doc.path = path;
                    doc.init();
                  });
                },
                child: Text("Clear"),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      doc.saveToJsonFile();
                      _originalContent = doc.saveToJsonString();
                      setState(() {});
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(color: colorOfSaveButton),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      saveDocToPng(doc);
                    },
                    child: Text('to PNG'),
                  ),
                ],
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
              Row(
                children: [
                  Text('Center Line'),
                  Checkbox(
                    value: doc.drawCenterLines,
                    onChanged: (v) {
                      setState(() {
                        doc.drawCenterLines = v!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 50, child: Text('GRID')),
                  buildGridLinesWidthButton(0),
                  buildGridLinesWidthButton(0.1),
                  buildGridLinesWidthButton(0.2),
                  buildGridLinesWidthButton(0.3),
                  buildGridLinesWidthButton(0.4),
                  buildGridLinesWidthButton(0.5),
                  buildGridLinesWidthButton(1),
                ],
              ),
              Row(
                children: [
                  SizedBox(width: 50, child: Text('SIZE')),
                  buildSetSizeButton(8),
                  buildSetSizeButton(12),
                  buildSetSizeButton(16),
                  buildSetSizeButton(20),
                  buildSetSizeButton(24),
                  buildSetSizeButton(32),
                  buildSetSizeButton(64),
                ],
              ),
              Row(
                children: [
                  Text('Color: '),
                  buildColorButton(Color.fromARGB(255, 0, 0xA0, 0xE3)),
                  buildColorButton(Color.fromARGB(255, 0, 0xFF, 0)),
                  buildColorButton(Color.fromARGB(255, 0xFF, 0xFF, 0)),
                  buildColorButton(Color.fromARGB(255, 0xFF, 0, 0xFF)),
                  buildColorButton(Color.fromARGB(255, 0, 0xFF, 0xFF)),
                  buildColorButton(Color.fromARGB(255, 0xFF, 0xFF, 0xFF)),
                ],
              ),
              Row(
                children: [
                  Text('Item: '),
                  buildItemTypeButton('roundSquare'),
                  buildItemTypeButton('circle'),
                  buildItemTypeButton('square'),
                ],
              ),
              Row(
                children: [
                  Text('Margin: '),
                  buildMarginButton(0.00),
                  buildMarginButton(0.05),
                  buildMarginButton(0.10),
                  buildMarginButton(0.15),
                  buildMarginButton(0.20),
                  buildMarginButton(0.25),
                  buildMarginButton(0.30),
                ],
              ),
              Text('File: ${doc.path}'),
              Text('Pixel size: ${doc.pixelSize}'),
              OutlinedButton(onPressed: (){
                applyStyleToAll();
              }, child: Text('Apply style to all')),
            ],
          ),
        ),
      ],
    );
  }
}
