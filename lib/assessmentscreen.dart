import 'dart:io';
import 'package:eureka/assessmenthandler.dart';
import 'package:eureka/widgets/custombutton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:docx_to_text/docx_to_text.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

double markSliderValue = 50;
String typeDropdownValue = 'Multiple Choice';
String strengthDropdownValue = 'Easy';
final ImagePicker _picker = ImagePicker();
XFile? image;
final byte = "";
Image? imageFIle = Image.asset('assets/images/placeholder.jpg');

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
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
              title: const Text('File Error'),
              content: const Text('Unsupported file type'),
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
    } else {}
  }

  Future<void> Imageget() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        image = selectedImage;
      });
      final bytes = await image!.readAsBytes();
      setState(() {
        imageFIle = Image.memory(bytes);
      });
    } else {
      print('No image selected.');
    }
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assessor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      height: 200,
                      child: TextField(
                        maxLines: 10,
                        controller: _controller,
                        decoration: const InputDecoration(
                            hintText:
                                'Enter Marking Guide or Upload Document in docx,txt',
                            border: OutlineInputBorder()),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    hoverColor: Colors.deepPurple.withOpacity(0.5),
                    onTap: () {
                      pickAndReadFile();
                    },
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: "Add File",
                            icon: Icon(Icons
                                .upload_file_rounded), // replace with your preferred icon
                            onPressed: () {
                              pickAndReadFile();
                            },
                          ),
                          Text('Add File')
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Container(
                  alignment: Alignment.center,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: image == null
                      ? Center(child: Text('No image selected'))
                      : imageFIle),
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              hoverColor: Colors.deepPurple.withOpacity(0.5),
              onTap: () {
                Imageget();
              },
              child: Container(
                height: 80,
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: "Add Script",
                      icon: Icon(Icons
                          .upload_file_rounded), // replace with your preferred icon
                      onPressed: () {
                        Imageget();
                      },
                    ),
                    Text('Add Script')
                  ],
                ),
              ),
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
                    ' ${markSliderValue.round()} % Leniency',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            CustomButton(
                text: 'Continue',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AssessmentOut(prompttext: _controller.text),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
