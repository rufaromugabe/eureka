import 'dart:convert';
import 'package:eureka/assessmentscreen.dart';
import 'package:eureka/main.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AssessmentOut extends StatefulWidget {
  const AssessmentOut({
    required this.prompttext,
    super.key,
  });

  final String prompttext;

  @override
  State<AssessmentOut> createState() => _AssessmentOutState();
}

class _AssessmentOutState extends State<AssessmentOut> {
  String? _response = "";
  bool _isLoading = false;
  Image? imageFIle = Image.asset('assets/images/placeholder.jpg');
  late final GenerationConfig _Config;
  int assesindex = 0;
  late final GenerativeModel _Model;
  String? mark;
  String? comment;

  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
      <({Image? image, String? text, bool fromUser})>[];

  @override
  void initState() {
    super.initState();
    _Config = GenerationConfig(
        temperature: 1,
        topP: 0.95,
        topK: 64,
        maxOutputTokens: 8192,
        responseMimeType: "application/json");
    _Model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: apiKey,
      generationConfig: _Config,
      systemInstruction: Content.text(
          'You are a an Ai marker you have ${lenSliderValue.round()} % Leniency and you return Json of marks as a percentage  in this format {mark: 80, comment: "Good work"} , also make comprehensive comments and use marking guide if attached'),
    );
  }

  Future<void> sendImagePrompt(String message) async {
    try {
      final pickedFile = image;
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final content = [
          Content.multi([
            TextPart(message),
            DataPart('image/jpeg', bytes),
          ])
        ];
        _generatedContent
            .add((image: Image.memory(bytes), text: message, fromUser: true));
        var response = await _Model.generateContent(content);
        imageFIle = Image.memory(bytes);
        var text = response.text;
        _response = response.text;
        var decodedResponse = jsonDecode(_response!);
        mark = decodedResponse['mark'].toString();
        comment = decodedResponse['comment'];

        _generatedContent.add((image: null, text: text, fromUser: false));
        if (text == null) {
          return;
        } else {
          setState(() {
            setState(() {
              assesindex = 1;
              _isLoading = false;
            });
          });
        }
      } else {}
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessement'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (assesindex == 0) ...[
                    Center(
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                  sendImagePrompt(widget.prompttext).then((_) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .deepPurple // This is the button color
                                  ),
                              child: _isLoading
                                  ? CircularProgressIndicator()
                                  : Text('Mark Assessment'),
                            ),
                    )
                  ],
                  if (assesindex == 1) ...[
                    SizedBox(
                      height: 20,
                    ),
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
                            child: Column(children: [
                          Container(
                            height: 360,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: imageFIle!,
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          if (mark != null && comment != null) ...[
                            Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: CircularPercentIndicator(
                                radius: 50.0,
                                lineWidth: 13.0,
                                animation: true,
                                percent: double.parse(mark!) / 100,
                                center: Text(
                                  "$mark%",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: Colors.green,
                              ),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Text(comment!)),
                          ]
                        ])),
                      ),
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
