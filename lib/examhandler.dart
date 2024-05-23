import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:document_file_save_plus/document_file_save_plus.dart';

class Examout extends StatefulWidget {
  final String text;
  const Examout({Key? key, required this.text}) : super(key: key);

  @override
  State<Examout> createState() => _ExamoutState();
}

class _ExamoutState extends State<Examout> {
  String? _response = "";
  int num = 0;
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final String apiKey = "AIzaSyDRiI5PgPjGCoWOjOZxSf0a5P_6lirLPQc";
  Future<String>? _chatFuture;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
    _chat = _model.startChat();
  }

  void _savFile(String data) {
    List<int> textBytes = utf8.encode(data);

    Uint8List textBytes1 = Uint8List.fromList(textBytes);
    DocumentFileSavePlus()
        .saveFile(textBytes1, "my_sample_file.docx", "text/plain");
  }

  @override
  Future<String> _sendChatMessage(String message) async {
    if (_chatFuture == null) {
      try {
        final response = await _chat.sendMessage(
          Content.text(message),
        );
        _response = response.text;

        if (_response == null) {
          print('Empty response.');
          return 'Empty response.';
        } else {
          num = 1;

          setState(() {});
          return _response!;
        }
      } catch (e) {
        print(e.toString());
        return 'Error: ${e.toString()}';
      }
    } else {
      return _response ?? 'No response yet.';
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text('MY Exam'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
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
                  child: Column(
                    children: [
                      if (num == 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    String markdown =
                                        _response!.replaceAll('**', '');
                                    String markdownTable = markdown;
                                    String plainTextTable = markdownTable
                                        .replaceAll('|', '\t')
                                        .replaceAll('---', '');
                                    Clipboard.setData(
                                        ClipboardData(text: plainTextTable));

                                    print('Copied');
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple),
                                child: Text('Copy')),
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    String markdown =
                                        _response!.replaceAll('**', '');
                                    String markdownTable = markdown;
                                    String plainTextTable = markdownTable
                                        .replaceAll('|', '\t')
                                        .replaceAll('---', '');
                                    _savFile(plainTextTable);

                                    print('Copied');
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple),
                                child: Text('Guide')),
                          ],
                        ),
                        MarkdownBody(data: _response!),
                      ] else ...[
                        Text('Click the button to get your exam paper here.'),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _chatFuture = _sendChatMessage(widget.text);
                            });
                            Clipboard.setData(ClipboardData(text: _response!));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.deepPurple // This is the button color
                              ),
                          child: FutureBuilder<String>(
                            future: _chatFuture,
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else {
                                return Text('Get Exam');
                              }
                            },
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
