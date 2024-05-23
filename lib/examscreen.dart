import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:docx_to_text/docx_to_text.dart';
import 'package:eureka/examhandler.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

double currentSliderValue = 50;
String dropdownValue = 'Multiple Choice';

class ExamScreen extends StatefulWidget {
  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final _controller = TextEditingController();

  Future<void> pickAndReadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String extension = path.extension(file.path);

      if (extension == '.docx') {
        final bytes = await file.readAsBytes();
        final fileContent = docxToText(bytes);
        _controller.text = fileContent;
      } else if (extension == '.txt') {
        String fileContent = await file.readAsString();
        _controller.text = fileContent;
      } else {
        _controller.text = 'Unsupported file type';
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Eureka Exam Planner'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 5,
              ),
              TextField(
                maxLines: 10,
                controller: _controller,
                decoration: InputDecoration(
                    hintText: 'Enter Exam Content',
                    border: OutlineInputBorder()),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Text(
                    'Question Type: ',
                    style: TextStyle(fontSize: 16),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue,
                    iconSize: 24,
                    elevation: 16,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    focusColor: Color.fromARGB(255, 1, 4, 19),
                    dropdownColor: Color.fromARGB(255, 1, 4, 19),
                    underline: Container(
                        decoration: BoxDecoration(color: Colors.blue)),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: <String>[
                      'Multiple Choice',
                      'True or False',
                      'Short Answer',
                      'Essay'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Slider(
                        value: currentSliderValue,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: currentSliderValue.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            currentSliderValue = value;
                          });
                        },
                      ),
                    ),
                    Text(
                      ' ${currentSliderValue.round()} Marks',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          pickAndReadFile();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple),
                        child: Text('Upload')),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  Examout(text: _controller.text),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple),
                        child: Text('Continue')),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'ExamPrep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Assesment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Ask',
          ),
        ]));
  }
}
