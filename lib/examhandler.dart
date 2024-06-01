import 'package:eureka/examscreen.dart';
import 'package:eureka/main.dart';
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
  int examindex = 0;
  int guidindex = 0;
  late final GenerativeModel _model;
  late final ChatSession _chat;

  Future<String>? _chatFuture;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: apiKey,
      systemInstruction: Content.text((guidindex == 0
          ? 'Write exam questions for the topic(s) with ${markSliderValue.round()} marks and the Question types should be set as $typeDropdownValue. The exam should be $strengthDropdownValue. Give instructions to the students.'
          : 'Give the Marking guide for the Exam above')),
    );
    _chat = _model.startChat();
  }

  Future<String> getExam(String message) async {
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
          examindex = 1;
          _loading = false;
        });
        return _response!;
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Connection Error'),
            content: Text(e.toString()),
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
        child: examindex == 0
            ? Center(
                child: _loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            getExam(widget.text);
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
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: Container(
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
                        child: Column(
                          children: [
                            if (examindex == 1) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                          Clipboard.setData(ClipboardData(
                                              text: plainTextTable));
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.deepPurple),
                                      child: Text('Copy')),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        guidindex = 1;
                                        _chatFuture = getExam(
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
