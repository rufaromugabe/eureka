import 'dart:async';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eureka/assessmenthandler.dart';
import 'package:eureka/takepicture.dart';
import 'package:eureka/widgets/custombutton.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:docx_to_text/docx_to_text.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

double lenSliderValue = 50;
final ImagePicker _picker = ImagePicker();
XFile? image;

Image? imageFIle = Image.asset('assets/images/placeholder.jpg');

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({
    super.key,
  });

  @override
  _AssessmentScreenState createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
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
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('File Error'),
              content: Text(" File not Supported"),
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
    }
  }

  Future<void> ImagegetCamera() async {
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
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
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
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    hoverColor: Colors.deepPurple.withOpacity(0.2),
                    onTap: () {
                      pickAndReadFile();
                    },
                    child: Container(
                      width: 80,
                      height: 100,
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
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
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
                            border: Border.all(
                              color: Colors.deepPurple,
                              width: 5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: image == null
                              ? Center(child: Text('No Image Script Uploaded'))
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
                              Imageget();
                            },
                            child: Container(
                              height: 80,
                              width: 100,
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
                                        .image), // replace with your preferred icon
                                    onPressed: () {
                                      Imageget();
                                    },
                                  ),
                                  Text('Add Gallery')
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              ImagegetCamera();
                            },
                            child: Container(
                              height: 80,
                              width: 100,
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
                                        .image), // replace with your preferred icon
                                    onPressed: () {
                                      ImagegetCamera();
                                    },
                                  ),
                                  Text('Add Camera')
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
              SizedBox(
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
              CustomButton(
                  icon: Icons.navigate_next_rounded,
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
      ),
    );
  }
}
