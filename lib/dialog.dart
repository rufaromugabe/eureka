import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:lottie/lottie.dart';

class ConversationPiece {
  final String agent;
  final String text;
  ConversationPiece({required this.agent, required this.text});
  factory ConversationPiece.fromJson(Map<String, dynamic> json) {
    return ConversationPiece(
      agent: json['agent'],
      text: json['text'],
    );
  }
}

class DialogAi extends StatefulWidget {
  const DialogAi({super.key});

  @override
  State<DialogAi> createState() => _DialogAiState();
}

class _DialogAiState extends State<DialogAi>
    with SingleTickerProviderStateMixin {
  FlutterTts flutterTts = FlutterTts();
  late final GenerativeModel _model;
  late final GenerationConfig _config;
  AnimationController? _animationController;
  final _controller = TextEditingController();
  late final ChatSession _chat;
  bool _loading = false;
  bool _talking = false;
  bool _isJohn = true;
  bool _ongoing = false;
  String? conversationJson;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);

    currentIndex = 0;

    _config = GenerationConfig(responseMimeType: "application/json");
    _model = GenerativeModel(
      generationConfig: _config,
      model: 'gemini-1.5-flash-latest',
      apiKey: "AIzaSyDsOduZY0h0N2mlPDgjLNzoD2d10TDxaKs",
      systemInstruction: Content.text(
          " you are  two  ai agents   that is  john and sheron  you respond with  json of john 's view and sheron's view on the user request do not repeat what you have alread said . you should make it more real as if  there are  3 people chating. the json format is  {\n  \"conversation\": [\n    {\n      \"agent\": \"John\",\n      \"text\": \"response\"\n    },\n    {\n      \"agent\": \"Sheron\",\n      \"text\": \"response\"\n    },\n    {\n      \"agent\": \"John\",\n      \"text\": \"Another responce.\"\n    },\n    {\n      \"agent\": \"Sheron\",\n      \"text\": \"another response.\"\n    }\n  ]\n}\n  you can be story characters if user need a story or anything where 2 people are involved or immitate a real senario where you take turns in a conversation or presentation  . Give the  script of latest  conversation only  when greeted John or Sheron should make introductions only not both"),
    );
    _chat = _model.startChat();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
    flutterTts.stop();
  }

  Future<String> getAnswer(String message) async {
    try {
      final response = await _chat.sendMessage(
        Content.text(message),
      );
      setState(() {
        conversationJson = response.text;
        print(conversationJson);
      });
      if (conversationJson == null) {
        return 'Empty response.';
      } else {
        setState(() {
          _loading = false;
          _ongoing = false;
          print(conversationJson);
        });

        handleConversation(conversationJson!);
        return conversationJson!;
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  List<ConversationPiece> parseConversation(String jsonString) {
    final parsed = json.decode(jsonString);
    final convJson = parsed['conversation'] as List;
    return convJson.map((json) => ConversationPiece.fromJson(json)).toList();
  }

  Future<void> handleConversation(String jsonString) async {
    List<ConversationPiece> conversationPieces = parseConversation(jsonString);

    Future<void> processPiece() async {
      _talking = true;

      if (currentIndex < conversationPieces.length) {
        var piece = conversationPieces[currentIndex];
        if (piece.agent == "John") {
          setState(() {
            _isJohn = true;
          });
          await flutterTts
              .setVoice({"name": "en-us-x-iol-local", "locale": "en-US"});
        } else if (piece.agent == "Sheron") {
          setState(() {
            _isJohn = false;
          });

          await flutterTts
              .setVoice({"name": "en-us-x-tpc-local", "locale": "en-US"});
        }
        await flutterTts.speak(piece.text);
        currentIndex++;
        flutterTts.setCompletionHandler(() {
          if (currentIndex < conversationPieces.length) {
            processPiece();
          } else {
            setState(() {
              _talking = false;
              _animationController?.stop();
              currentIndex = 0;
              conversationPieces.clear();
              _controller.clear();
            });
          }
        });
      }
    }

    await processPiece();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Dialog'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  height: 250,
                  child: Center(
                    child: _talking
                        ? Column(children: [
                            Text(
                              _isJohn ? "John's Turn" : "Sheron's Turn",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Lottie.asset(
                              'assets/images/talk4.json',
                              repeat: true,
                              height: 200,
                            ),
                          ])
                        : Column(children: [
                            const Text(
                              "Your Turn",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Lottie.asset(
                              'assets/images/talk4.json',
                              controller: _animationController,
                              repeat: true,
                              height: 200,
                            ),
                          ]),
                  )),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter something to discuss',
                  border: OutlineInputBorder(),
                ),
                controller: _controller,
                readOnly: _loading,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _ongoing = true;
                        });
                        FocusScope.of(context).unfocus();
                        await getAnswer("keep going");
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      child: _ongoing
                          ? const CircularProgressIndicator()
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat),
                                SizedBox(width: 10),
                                Text('keep going'),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });
                        FocusScope.of(context).unfocus();
                        await getAnswer(_controller.text);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Suggest'),
                                SizedBox(width: 10),
                                Icon(Icons.send),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
