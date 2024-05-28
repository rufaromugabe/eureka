import 'package:eureka/assessmentscreen.dart';
import 'package:eureka/widgets/custombutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  String _apiKey = 'AIzaSyDRiI5PgPjGCoWOjOZxSf0a5P_6lirLPQc';
  String? _response = "";
  Image? imageFIle = Image.asset('assets/images/placeholder.jpg');

  late final GenerativeModel _Model;

  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
      <({Image? image, String? text, bool fromUser})>[];

  @override
  void initState() {
    super.initState();
    _Model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: _apiKey,
      systemInstruction: Content.text(
          'You are a an Ai marker you return Json of marks as a percentage  in this format {mark: 80, comment: "Good work"}'),
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
        _generatedContent.add((image: null, text: text, fromUser: false));
        if (text == null) {
          return;
        } else {
          setState(() {
            print(text);
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
                  CustomButton(
                      text: 'Mark Script',
                      onPressed: () {
                        sendImagePrompt(widget.prompttext);
                      }),
                  if (_generatedContent.isNotEmpty) ...[
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
                          imageFIle!,
                          MarkdownBody(data: _response!),
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
