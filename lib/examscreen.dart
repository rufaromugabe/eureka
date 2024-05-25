import 'dart:io';
import 'package:eureka/widgets/custombutton.dart';
import 'package:eureka/widgets/customdropdown.dart';
import 'package:path/path.dart' as path;
import 'package:docx_to_text/docx_to_text.dart';
import 'package:eureka/examhandler.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

double markSliderValue = 50;
String typeDropdownValue = 'Multiple Choice';
String strengthDropdownValue = 'Easy';

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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('File Error'),
              content: Text('Unsupported file type'),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {}
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            TextField(
              maxLines: 8,
              controller: _controller,
              decoration: InputDecoration(
                  hintText: 'Enter Exam Content', border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    CustomDropdown(
                      value: typeDropdownValue,
                      items: [
                        'Multiple Choice',
                        'True or False',
                        'Short Answer',
                        'Essay'
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          typeDropdownValue = newValue!;
                        });
                      },
                    )
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Strength: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    CustomDropdown(
                      value: strengthDropdownValue,
                      items: ['Very Easy', 'Easy', 'Hard', 'Very Hard'],
                      onChanged: (String? newValue) {
                        setState(() {
                          strengthDropdownValue = newValue!;
                        });
                      },
                    )
                  ],
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Slider(
                      value: markSliderValue,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (double value) {
                        setState(() {
                          markSliderValue = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    ' ${markSliderValue.round()} Marks',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomButton(
                      text: 'Upload',
                      onPressed: () {
                        pickAndReadFile();
                      }),
                  CustomButton(
                      text: 'Continue',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                Examout(text: _controller.text),
                          ),
                        );
                      })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
