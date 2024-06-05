import 'dart:async';
import 'dart:io';

import 'package:docx_to_text/docx_to_text.dart';
import 'package:eureka/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class AskAi extends StatefulWidget {
  const AskAi({
    super.key,
  });

  @override
  AskAiState createState() => AskAiState();
}

class AskAiState extends State<AskAi> {
  final _controller = TextEditingController();
  final _controller1 = TextEditingController();
  int askindex = 0;
  String? _response = "";
  String data = "no data provided please upload a content";
  late final GenerativeModel _model;
  late final ChatSession _chat;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: apiKey,
      systemInstruction: Content.text(
          "Use this data provided as your knowledge to respond to all questions strictly "),
    );
    _chat = _model.startChat();
  }

  Future<String> getResponse(String message) async {
    setState(() {
      _loading = true;
    });
    try {
      final response = await _chat.sendMessage(
        Content.text(message),
      );
      _response = response.text;

      if (_response == null) {
        return 'Empty response.';
      } else {
        setState(() {
          _loading = false;
        });
        return _response!;
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Connection Error'),
              content: Text(e.toString()),
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

      return 'Error: ${e.toString()}';
    }
  }

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
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask Document'),
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
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(178, 76, 79, 175),
                        border: Border.all(
                          width: 2,
                        ),
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
                            hintText: 'Enter Documents to Explore ',
                            border: OutlineInputBorder(),
                            hintStyle: TextStyle(color: Colors.black)),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _controller1,
                    decoration: const InputDecoration(
                        hintText: 'Ask your document',
                        border: OutlineInputBorder()),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        data = _controller.text;
                        getResponse("${_controller1.text} from $data");
                        askindex = 1;
                      });
                    },
                    icon: const Icon(Icons.send)),
              ]),
              if (askindex == 1) ...[
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 350,
                  width: 500,
                  constraints: const BoxConstraints(maxWidth: 800),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: SingleChildScrollView(
                    child: Container(
                        child: _loading
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                ],
                              )
                            : MarkdownBody(data: _response!)),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
