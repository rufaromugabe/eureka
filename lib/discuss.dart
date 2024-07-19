import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:eureka/translateapi.dart';
import 'package:eureka/widgets/customappbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class DiscussAi extends StatefulWidget {
  const DiscussAi({super.key});

  @override
  State<DiscussAi> createState() => _DiscussAiState();
}

class _DiscussAiState extends State<DiscussAi>
    with SingleTickerProviderStateMixin {
  final TextToSpeechAPI ttsAPI = TextToSpeechAPI();
  final AudioPlayer audioPlayer = AudioPlayer();
  late final GenerativeModel _model;
  late final GenerationConfig _config;
  AnimationController? _animationController;
  final _controller = TextEditingController();
  late final ChatSession _chat;
  bool _loading = false;
  bool _talking = false;
  bool _isJohn = true;
  String? chatitem =
      "Let's discuss something or have a some fun with John and Sheron in the room";
  String? conversationJson;
  String conversationHistory = "";
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
          " you are  two  ai agents   that is  john and sheron  you respond with  json of john 's view and sheron's view on the user request do not repeat what you have alread said . you should make it more real as if  there are  3 people chating. the json format is  {\n  \"conversation\": [\n    {\n      \"agent\": \"John\",\n      \"text\": \"response\"\n    },\n    {\n      \"agent\": \"Sheron\",\n      \"text\": \"response\"\n    },\n    {\n      \"agent\": \"John\",\n      \"text\": \"Another responce.\"\n    },\n    {\n      \"agent\": \"Sheron\",\n      \"text\": \"another response.\"\n    }\n  ]\n}\n  you can be story characters if user need a story or anything where 2 people are involved or immitate a real senario where you take turns in a conversation or presentation  . Give the  script of latest  conversation only  when greeted John or Sheron should make introductions only not both. Have multiple conversation  turns where possible ."),
    );
    _chat = _model.startChat();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
    audioPlayer.dispose();
  }

  Future<String> getAnswer(String message) async {
    try {
      final response = await _chat.sendMessage(
        Content.text(message),
      );
      setState(() {
        conversationJson = response.text;
        print(conversationJson);
        // Step 2: Append new message to the chat history
        conversationHistory += "\nUser: ${_controller.text}\n${response.text!}";
      });
      if (conversationJson == null) {
        return 'Empty response.';
      } else {
        setState(() {
          _loading = false;
          print(conversationJson);
        });

        _speak(conversationJson!);
        return conversationJson!;
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  void copyChatHistory() {
    String formatted = conversationHistory
        .replaceAll('}, ', '\n')
        .replaceAll(RegExp(r'[\{\}\[\]]'), '')
        .replaceAll('"agent": ', '')
        .replaceAll('"conversation": ', '')
        .replaceAll(', "text"', '')
        .replaceAll('"', '');
    Clipboard.setData(ClipboardData(text: formatted)).then((_) {
      print("Chat history copied to clipboard.");
    });
  }

  List<ConversationPiece> parseConversation(String jsonString) {
    final parsed = json.decode(jsonString);
    final convJson = parsed['conversation'] as List;
    return convJson.map((json) => ConversationPiece.fromJson(json)).toList();
  }

  void _speak(String jsonString) async {
    List<ConversationPiece> conversationPieces = parseConversation(jsonString);

    Future<void> processPiece() async {
      if (currentIndex < conversationPieces.length) {
        var piece = conversationPieces[currentIndex];
        if (piece.agent == "John") {
          const String voiceName = "en-US-Wavenet-D"; // Example voice name
          const String languageCode = "en-US"; // Example language code

          setState(() {
            _talking = false;
            _isJohn = true;
          });
          final audioContent =
              await ttsAPI.synthesizeText(piece.text, voiceName, languageCode);

          if (audioContent != null) {
            setState(() {
              _talking = true;
              chatitem = piece.text;
            });

            Uint8List audioBytes = base64Decode(audioContent);
            // Ensure UI interactions happen on the main thread
            await Future.microtask(() async {
              await audioPlayer.setSourceBytes(audioBytes);
              await audioPlayer.resume();
              await audioPlayer.onPlayerComplete.first;
            });
          }
        } else if (piece.agent == "Sheron") {
          const String voiceName = "en-US-Wavenet-F"; // Example voice name
          const String languageCode = "en-US"; // Example language code
          setState(() {
            _talking = false;
            _isJohn = false;
          });
          final audioContent =
              await ttsAPI.synthesizeText(piece.text, voiceName, languageCode);
          if (audioContent != null) {
            setState(() {
              _talking = true;
              chatitem = piece.text;
            });
            Uint8List audioBytes = base64Decode(audioContent);
            // Ensure UI interactions happen on the main thread
            await Future.microtask(() async {
              await audioPlayer.setSourceBytes(audioBytes);
              await audioPlayer.resume();
              await audioPlayer.onPlayerComplete.first;
            });
          }
        }
        currentIndex++;

        if (currentIndex < conversationPieces.length) {
          await processPiece();
        } else {
          setState(() {
            _talking = false;
            chatitem = " Its now your turn 😊";
            _animationController?.stop();
            currentIndex = 0;
            conversationPieces.clear();
            _controller.clear();
          });
        }
      }
    }

    await processPiece();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        titleText: 'Discuss AI',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              copyChatHistory();
              final snackBar = SnackBar(
                /// need to set following properties for best effect of awesome_snackbar_content
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Success',
                  message: ' Copied to clipboard',
                  contentType: ContentType.success,
                ),
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);
            },
          ),
        ],
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
                              _isJohn ? "John Speaking" : "Sheron ",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Lottie.asset(
                              'assets/images/voice.json',
                              repeat: true,
                              height: 200,
                            ),
                          ])
                        : Column(children: [
                            const Text(
                              "..........",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Lottie.asset(
                              'assets/images/voice.json',
                              controller: _animationController,
                              repeat: true,
                              height: 200,
                            ),
                          ]),
                  )),
              Container(
                padding: const EdgeInsets.all(10),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 18, 4, 43),
                  borderRadius: BorderRadius.circular(10), // Round the corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), // Shadow color
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _isJohn ? "$chatitem " : "$chatitem",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                decoration: InputDecoration(
                  suffixIcon: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(),
                        )
                      : IconButton(
                          onPressed: () async {
                            setState(() {
                              _loading = true;
                            });
                            FocusScope.of(context).unfocus();
                            await getAnswer(_controller.text);
                          },
                          icon: const Icon(Icons.send)),
                  hintText: 'Enter something to discuss',
                  border: const OutlineInputBorder(),
                ),
                controller: _controller,
                readOnly: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
