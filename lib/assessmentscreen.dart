import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:eureka/assessmenthandler.dart';
import 'package:eureka/takepicture.dart';
import 'package:eureka/widgets/customappbar.dart';
import 'package:eureka/widgets/custombutton.dart';
import 'package:eureka/widgets/gradientbutton.dart';
import 'package:eureka/widgets/nextbutton.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

double lenSliderValue = 50;
final ImagePicker _picker = ImagePicker();
XFile? image;
Image? imageFIle = Image.asset('assets/images/placeholder.png');

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
      appBar: const GradientAppBar(
        titleText: 'AI Assessment',
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Container(
                  alignment: Alignment.center,
                  height: 80,
                  child: TextField(
                    maxLines: 10,
                    controller: _controller,
                    decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.black,
                            size: 40,
                          ),
                          onPressed: pickAndReadFile,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(148, 255, 255, 255),
                        hintText: 'Enter Marking guide or Answers ',
                        border: const OutlineInputBorder(),
                        hintStyle: const TextStyle(color: Colors.black)),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(91, 255, 255, 255)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            alignment: Alignment.center,
                            height: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: imageFIle,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomButton(
                              icon: Icons.upload_file,
                              text: 'Upload Script',
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 200,
                                      decoration: const BoxDecoration(
                                        color: Color.fromARGB(116, 13, 6, 85),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            GradientButton(
                                                iconData: Icons.image,
                                                tooltip: "Add Gallery",
                                                onPressed: () {
                                                  imageGet();
                                                  Navigator.pop(context);
                                                }),
                                            GradientButton(
                                                iconData: Icons.camera_alt,
                                                tooltip: "Add Camera",
                                                onPressed: () {
                                                  imageGetCamera(context);
                                                  Navigator.pop(context);
                                                }),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
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
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width > 800
                      ? 500
                      : MediaQuery.of(context).size.width / 1.2,
                  child: Nextbutton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              AssessmentOut(prompttext: _controller.text),
                        ),
                      );
                    },
                    text: 'Continue',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
