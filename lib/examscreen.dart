import 'dart:io';

import 'package:docx_to_text/docx_to_text.dart';
import 'package:eureka/examhandler.dart';
import 'package:eureka/widgets/custombutton.dart';
import 'package:eureka/widgets/customdropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

double markSliderValue = 50;
double qsnSliderValue = 10;
String typeDropdownValue = 'Multiple Choice';
String strengthDropdownValue = 'Easy';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final _controller = TextEditingController();

  Future<void> pickAndReadFile() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        return;
      }
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String extension = path.extension(file.path);

      if (extension == '.pdf') {
        final PdfDocument document =
            PdfDocument(inputBytes: file.readAsBytesSync());
        String text = PdfTextExtractor(document).extractText();
        document.dispose();
        _controller.text = text;
      } else if (extension == '.docx') {
        final bytes = await file.readAsBytes();
        final fileContent = docxToText(bytes);
        _controller.text = fileContent;
      } else if (extension == '.txt') {
        String fileContent = await file.readAsString();
        _controller.text = fileContent;
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('File Error'),
                content: const Text(" File not Supported"),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  @override
  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Generator'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 300,
              width: MediaQuery.of(context).size.width / 1.1,
              child: TextField(
                maxLines: 8,
                controller: _controller,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color.fromARGB(148, 255, 255, 255),
                  hintText:
                      'Enter Exam Content i.e Course content or Outlines ',
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(color: Colors.black),
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Type: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      CustomDropdown(
                        value: typeDropdownValue,
                        items: const [
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
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Strength: ',
                        style: TextStyle(fontSize: 16),
                      ),
                      CustomDropdown(
                        value: strengthDropdownValue,
                        items: const ['Very Easy', 'Easy', 'Hard', 'Very Hard'],
                        onChanged: (String? newValue) {
                          setState(() {
                            strengthDropdownValue = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 40,
                    width: 220,
                    child: Slider(
                      value: markSliderValue,
                      min: 1,
                      max: 100,
                      divisions: 100,
                      onChanged: (double value) {
                        setState(() {
                          markSliderValue = value;
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  ' ${markSliderValue.round()} Marks ',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 40,
                    width: 220,
                    child: Slider(
                      label: 'Questions',
                      value: qsnSliderValue.clamp(
                          2.0,
                          typeDropdownValue == "Essay"
                              ? 10.0
                              : (typeDropdownValue == "Short Answer"
                                  ? 30.0
                                  : 50.0)),
                      min: 2,
                      max: typeDropdownValue == "Essay"
                          ? 10
                          : (typeDropdownValue == "Short Answer" ? 30 : 50),
                      divisions: 100,
                      onChanged: (double value) {
                        setState(() {
                          qsnSliderValue = value.clamp(
                              2.0,
                              typeDropdownValue == "Essay"
                                  ? 10.0
                                  : (typeDropdownValue == "Short Answer"
                                      ? 30.0
                                      : 50.0));
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  ' ${qsnSliderValue.round()} Qtns  ',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomButton(
                  icon: Icons.file_upload,
                  text: 'Upload',
                  onPressed: () {
                    pickAndReadFile();
                  },
                ),
                CustomButton(
                  icon: Icons.navigate_next,
                  text: 'Continue',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Examout(text: _controller.text),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
