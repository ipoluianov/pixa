import 'dart:io';
import 'dart:ui';

import 'doc.dart';
import 'doc_painter.dart';

void saveDocToPng(Document doc) async {
  var recorder = PictureRecorder();
  var canvas = Canvas(
    recorder,
    Rect.fromLTWH(
      0.0,
      0.0,
      doc.width * doc.pixelSize,
      doc.height * doc.pixelSize,
    ),
  );
  var painter = DocPainter(doc);
  painter.paint(
    canvas,
    Size(doc.width * doc.pixelSize, doc.height * doc.pixelSize),
  );
  var pic = recorder.endRecording();
  var image = await pic.toImage(
    (doc.width * doc.pixelSize).round(),
    (doc.height * doc.pixelSize).round(),
  );
  var bs = await image.toByteData(format: ImageByteFormat.png);
  var bytes = bs!.buffer.asUint8List();

  // Save to file doc.path + '.png'
  String path = doc.path;
  path = path.replaceAll('.pixa', '.png');
  var file = File(path);
  file.writeAsBytesSync(bytes);
}
