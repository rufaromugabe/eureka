import 'package:eureka/examscreen.dart';
import 'package:eureka/main.dart';
import 'package:eureka/widgets/custombutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Examout extends StatefulWidget {
  final String text;
  const Examout({super.key, required this.text});

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
          ? 'Write exam questions for the topic(s) with ${markSliderValue.round()} marks, ${qsnSliderValue.round()}Questions and the Question types should be set as $typeDropdownValue. The exam should be $strengthDropdownValue. Give instructions to the students. Questions may carry diffirent marks'
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Exam'),
      ),
      body: Center(
        child: examindex == 0
            ? Center(
                child: _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            getExam(widget.text);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(8.0),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: FutureBuilder<String>(
                          future: _chatFuture,
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else {
                              return const SizedBox(
                                width: 100,
                                height: 40,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.get_app_sharp),
                                    Text('Get Exam'),
                                  ],
                                ),
                              );
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
                                  CustomButton(
                                    text: 'Copy',
                                    icon: Icons.copy,
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
                                  ),
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
                                      padding: const EdgeInsets.all(8.0),
                                      backgroundColor: Colors.deepPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: FutureBuilder<String>(
                                      future: _chatFuture,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else {
                                          return const Row(
                                            children: [
                                              Icon(Icons
                                                  .question_answer_outlined),
                                              Text('Marking guild'),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              MarkdownBody(data: _response!),
                            ] else
                              ...[]
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
