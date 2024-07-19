import 'dart:async';
import 'dart:convert';
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
  String? _hintresponse = "";
  String data = "no data provided please upload a content";
  late final GenerativeModel _model;
  late final GenerativeModel _hintmodel;
  late final GenerationConfig _config;
  List<String> _suggestions = [];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _config = GenerationConfig(
        temperature: 1.2,
        topP: 0.9,
        topK: 128,
        maxOutputTokens: 256,
        responseMimeType: "application/json");
    _hintmodel = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
        generationConfig: _config,
        systemInstruction: Content.text(
            'When responding to a prompt, suggest 10 shortest search queries related to the data provided only. return the queries in the format of Json list [{suggest: "Summerize document"}, {suggest:"Evaluate the ANOVA"}, {suggest:"Get timeline of budget"}]'));
    _model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: apiKey,
      systemInstruction: Content.text(
          "Use this data provided as your context  but not limited to it. "),
    );
  }

  void _getSuggestions(String text) async {
    if ((text.startsWith('@') && _controller.text != "")) {
      try {
        final hintresponse =
            await _hintmodel.generateContent([Content.text(_controller.text)]);
        _hintresponse = hintresponse.text;
        if (_hintresponse != null) {
          List<dynamic> decodedResponse =
              json.decode(_hintresponse!) as List<dynamic>;
          _suggestions = decodedResponse
              .map((item) => item as Map<String, dynamic>)
              .map((item) => item['suggest'])
              .toList()
              .cast<String>();
          setState(() {
            FocusScope.of(context).unfocus();
          });
        } else {
          _suggestions = [];
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
      }
    } else {
      _suggestions = [];
    }
    setState(() {});
  }

  Future<String> getResponse(String message) async {
    setState(() {
      _loading = true;
    });
    try {
      final response = await _model.generateContent([Content.text(message)]);
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
        setState(() {
          _loading = false;
        });
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
        _getSuggestions('@');
      } else if (extension == '.docx') {
        final bytes = await file.readAsBytes();
        final fileContent = docxToText(bytes);
        _controller.text = fileContent;
        _getSuggestions('@');
      } else if (extension == '.txt') {
        String fileContent = await file.readAsString();
        _controller.text = fileContent;

        _getSuggestions('@');
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
                      height: 80,
                      child: TextField(
                        maxLines: 10,
                        controller: _controller,
                        onChanged: (text) => _getSuggestions(text),
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
                    onTap: _controller1.clear,
                    onChanged: (text) => _getSuggestions(text),
                    decoration: const InputDecoration(
                      hintText: 'Ask your document',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      data = _controller.text;
                      getResponse("${_controller1.text} from $data");
                      askindex = 1;
                      FocusScope.of(context).unfocus();
                    });
                  },
                  icon: const Icon(Icons.send),
                ),
              ]),
              if (_suggestions.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 150, // specify the height of the GridView
                  child: GridView.count(
                    scrollDirection: Axis.horizontal,
                    crossAxisCount: 3, // specify the number of columns
                    childAspectRatio: 0.2, // adjust the aspect ratio as needed
                    children: _suggestions
                        .map((suggestion) => FilterChip(
                              label: Text(suggestion),
                              onSelected: (selected) {
                                _controller1.text = suggestion;
                                _suggestions = [];
                                setState(() {});
                              },
                            ))
                        .toList(),
                  ),
                ),
              ],
              if (askindex == 1) ...[
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 430,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 24, 2, 61),
                    borderRadius: BorderRadius.circular(8.0),
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
