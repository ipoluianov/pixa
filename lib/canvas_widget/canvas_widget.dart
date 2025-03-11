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

  Widget buildSetSizeButton(int size) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              doc.pixelSize = size.toDouble();
            });
          },
          child: Text("size $size"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilesWidget(),
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
                  doc.pixelSize = 16 * _scale;
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
        SizedBox(
          width: 300,
          child: Column(
            children: [
              Text('Tools'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    doc.init();
                  });
                },
                child: Text("Clear"),
              ),
              ElevatedButton(
                onPressed: () {
                  saveDocToPng(doc);
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
              buildSetSizeButton(16),
              buildSetSizeButton(20),
              buildSetSizeButton(24),
              buildSetSizeButton(32),
            ],
          ),
        ),
      ],
    );
  }
}
