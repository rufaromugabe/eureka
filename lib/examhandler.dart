import 'package:eureka/examscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Examout extends StatefulWidget {
  final String text;
  const Examout({Key? key, required this.text}) : super(key: key);

  @override
  State<Examout> createState() => _ExamoutState();
}

class _ExamoutState extends State<Examout> {
  String? _response = "";
  int num = 0;
  int guide = 0;
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final String apiKey = "AIzaSyDRiI5PgPjGCoWOjOZxSf0a5P_6lirLPQc";
  Future<String>? _chatFuture;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: apiKey,
      systemInstruction: Content.text((guide == 0
          ? 'Write exam questions for the topic(s) with ${currentSliderValue.round()} marks and the Question types should be set as $dropdownValue. Give instructions to the students.'
          : 'Give the Marking guide for the Exam above')),
    );
    _chat = _model.startChat();
  }

  Future<String> _sendChatMessage(String message) async {
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
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 14, 9, 22),
        title: Text('My Exam'),
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
                                  guide = 1;
                                  _chatFuture = _sendChatMessage(
                                      'Give the Marking guide for the Exam above');
                                });
                                Clipboard.setData(
                                    ClipboardData(text: _response!));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .deepPurple // This is the button color
                                  ),
                              child: FutureBuilder<String>(
                                future: _chatFuture,
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else {
                                    return Text('Marking guild');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        MarkdownBody(data: _response!),
                      ] else ...[
                        Text('Click the button to get your exam paper.'),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _chatFuture = _sendChatMessage(widget.text);
                            });
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
