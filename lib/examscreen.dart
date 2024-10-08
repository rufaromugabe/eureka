import 'dart:io';

import 'package:docx_to_text/docx_to_text.dart';
import 'package:eureka/examhandler.dart';
import 'package:eureka/widgets/customappbar.dart';
import 'package:eureka/widgets/customdropdown.dart';
import 'package:eureka/widgets/nextbutton.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

double markSliderValue = 50;
String typeDropdownValue = 'Multiple Choice';
String strengthDropdownValue = 'Easy';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  ExamScreenState createState() => ExamScreenState();
}

class ExamScreenState extends State<ExamScreen> {
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
      appBar: const GradientAppBar(
        titleText: 'Create Exam',
      ), //AppBar
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  maxLines: 8,
                  controller: _controller,
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      icon: const Icon(
                        Icons.attach_file,
                        color: Colors.black,
                        size: 40,
                      ),
                      onPressed: () {
                        pickAndReadFile();
                      },
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(148, 255, 255, 255),
                    hintText:
                        'Upload Exam Content or Type a Topic (PDF, DOCX, TXT)',
                    border: const OutlineInputBorder(),
                    hintStyle: const TextStyle(color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
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
                  height: 100,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2.0),
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
                const SizedBox(
                  width: 15,
                )
              ],
            ),
            const SizedBox(
              width: 50,
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width > 800
                  ? 500
                  : MediaQuery.of(context).size.width / 1.2,
              child: Nextbutton(
                  text: 'Continue',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Examout(text: _controller.text),
                    ));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
