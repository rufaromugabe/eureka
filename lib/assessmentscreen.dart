import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:eureka/assessmenthandler.dart';
import 'package:eureka/takepicture.dart';
import 'package:eureka/widgets/custombutton.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

double lenSliderValue = 50;
final ImagePicker _picker = ImagePicker();
XFile? image;
Image? imageFIle = Image.asset('assets/images/placeholder.jpg');

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({
    super.key,
  });

  @override
  AssessmentScreenState createState() => AssessmentScreenState();
}

class AssessmentScreenState extends State<AssessmentScreen> {
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

  Future<void> imageGetCamera(context) async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: firstCamera),
      ),
    );
    if (result != null) {
      setState(() {
        imageFIle = result;
      });
    }
  }

  Future<void> imageGet() async {
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
    } else {}
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assessor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  InkWell(
                    hoverColor: Colors.deepPurple.withOpacity(0.2),
                    onTap: () {
                      pickAndReadFile();
                    },
                    child: Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(178, 76, 79, 175),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: "Add File",
                            icon: const Icon(Icons.upload_file_rounded),
                            onPressed: () {
                              pickAndReadFile();
                            },
                          ),
                          const Text('Add File')
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      height: 100,
                      child: TextField(
                        maxLines: 10,
                        controller: _controller,
                        decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color.fromARGB(148, 255, 255, 255),
                            hintText:
                                'Enter Marking guide or Question content ',
                            border: OutlineInputBorder(),
                            hintStyle: TextStyle(color: Colors.black)),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 12, 6, 26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          alignment: Alignment.center,
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(148, 255, 255, 255),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: image == null
                              ? const Center(
                                  child: Text(
                                  'Your Script will appear here',
                                  style: TextStyle(color: Colors.black),
                                ))
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: imageFIle,
                                )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              imageGet();
                            },
                            child: Container(
                              height: 80,
                              width: 100,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(178, 76, 79, 175),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    tooltip: "Add Script",
                                    icon: const Icon(Icons
                                        .image), // replace with your preferred icon
                                    onPressed: () {
                                      imageGet();
                                    },
                                  ),
                                  const Text('Add Gallery')
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              imageGetCamera(context);
                            },
                            child: Container(
                              height: 80,
                              width: 100,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(178, 76, 79, 175),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    tooltip: "Add Script",
                                    icon: const Icon(Icons.image),
                                    onPressed: () {
                                      imageGetCamera(context);
                                    },
                                  ),
                                  const Text('Add Camera')
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Slider(
                      value: lenSliderValue,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      onChanged: (double value) {
                        setState(() {
                          lenSliderValue = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    ' ${lenSliderValue.round()} % Leniency',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              SizedBox(
                width: 100,
                height: 40,
                child: CustomButton(
                    icon: Icons.navigate_next_rounded,
                    text: 'Continue',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AssessmentOut(prompttext: _controller.text),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
