import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:pixa/doc/doc.dart';
import 'package:pixa/doc/png_saver.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesWidget extends StatefulWidget {
  final Function(String) onFileSelected;

  const FilesWidget(this.onFileSelected, {super.key});

  @override
  State<StatefulWidget> createState() {
    return FilesWidgetState();
  }
}

class FilesWidgetState extends State<FilesWidget> {
  String _folder = "c:/temp/";
  List<String> files = [];

  String currentFile = "";

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      _folder = prefs.getString("dir") ?? "c:/temp/";
      loadFiles();
    });
  }

  void loadFiles() async {
    Directory directory = Directory(_folder);

    this.files.clear();

    // Читаем содержимое директории
    List<FileSystemEntity> files = directory.listSync();

    for (FileSystemEntity file in files) {
      if (file is File) {
        // only *.piza files
        if (file.path.endsWith(".pixa")) {
          this.files.add(file.path);
        }
      }
    }

    setState(() {});
  }

  void selectDirectory() async {
    final String? directoryPath = await getDirectoryPath();
    if (directoryPath == null) {
      return;
    }

    _folder = directoryPath.toString();
    loadFiles();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("dir", _folder);
  }

  void selectFile(String filePath) async {
    currentFile = filePath;
    widget.onFileSelected(filePath);
    setState(() {});
  }

  void regeneragePngFiles() {
    for (String file in files) {
      if (file.endsWith('.pixa')) {
        Document doc = Document();
        doc.loadFromJsonFile(file);
        saveDocToPng(doc);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Container(
        child: Column(
          children: [
            Text(_folder),
            ElevatedButton(
              onPressed: () {
                Document doc = Document();
                doc.path = "$_folder/new.pixa";
                doc.saveToJsonFile();
                loadFiles();
              },
              child: Text("Create Doc"),
            ),
            ElevatedButton(
              onPressed: () {
                selectDirectory();
              },
              child: Text("Open directory"),
            ),
            ElevatedButton(
              onPressed: () {
                loadFiles();
              },
              child: Text("Update"),
            ),
            ElevatedButton(
              onPressed: () {
                regeneragePngFiles();
              },
              child: Text("Regenerate PNG"),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  files.map((String file) {
                    var shortFileName = File(file).uri.pathSegments.last;

                    return GestureDetector(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: EdgeInsets.all(5),
                          color:
                              file == currentFile ? Colors.blue : Colors.black,
                          child: Text(shortFileName),
                        ),
                      ),
                      onTap: () {
                        selectFile(file);
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
