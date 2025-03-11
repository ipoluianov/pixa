import 'dart:io';

import 'package:flutter/material.dart';

class FilesWidget extends StatefulWidget {
  const FilesWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return FilesWidgetState();
  }
}

class FilesWidgetState extends State<FilesWidget> {
  String folder = "c:/temp/";
  List<String> files = [];

  String currentFile = "";

  void loadFiles() async {
    Directory directory = Directory(folder);

    this.files.clear();

    // Читаем содержимое директории
    List<FileSystemEntity> files = directory.listSync();

    for (FileSystemEntity file in files) {
      if (file is File) {
        this.files.add(file.path);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                loadFiles();
              },
              child: Text("Load files"),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(files[index]),
                    textColor: currentFile == files[index]
                        ? Colors.blue
                        : Colors.black,
                    onTap: () {
                      setState(() {
                        currentFile = files[index];
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
