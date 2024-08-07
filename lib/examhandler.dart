import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:eureka/examscreen.dart';
import 'package:eureka/splashscreen.dart';
import 'package:eureka/widgets/customappbar.dart';
import 'package:eureka/widgets/custombutton.dart';
import 'package:eureka/widgets/gradientbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:loader_overlay/loader_overlay.dart';

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

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      systemInstruction: Content.text((guidindex == 0
          ? 'Write exam questions for the topic(s) with ${markSliderValue.round()} marks, the Questions type should be set as $typeDropdownValue. The exam should be $strengthDropdownValue. Give instructions to the students. Questions may carry diffirent marks . Use best formatting for the exam paper.'
          : 'Give the Marking guide for the Exam above')),
    );
    _chat = _model.startChat();
  }

  Future<String> getExam(String message) async {
    setState(() {});
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
          context.loaderOverlay.hide();
        });
        return _response!;
      }
    } catch (e) {
      if (mounted) {
        context.loaderOverlay.hide();
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
      appBar: const GradientAppBar(
        titleText: 'Exam Paper',
      ),
      body: LoaderOverlay(
        overlayColor: Colors.black.withOpacity(0.8),
        child: Center(
          child: examindex == 0
              ? Center(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white),
                          ),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            children: [
                              const Text(
                                'Exam Details',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Exam Type : $typeDropdownValue",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "Exam Marks : ${markSliderValue.round()} marks",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "Exam Strength : $strengthDropdownValue",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18, // Adjusted font size
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      GradientButton(
                          iconData: Icons.download,
                          onPressed: () {
                            context.loaderOverlay.show(
                              widgetBuilder: (progress) {
                                return const Center(
                                    child: SpinKitCubeGrid(
                                  color: Color.fromARGB(255, 90, 95, 228),
                                  size: 100.0,
                                ));
                              },
                            );
                            setState(() {
                              getExam(widget.text);
                            });
                          },
                          tooltip: 'Get Paper'),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
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
                                            String plainTextTable =
                                                markdownTable
                                                    .replaceAll('|', '\t')
                                                    .replaceAll('---', '');
                                            Clipboard.setData(ClipboardData(
                                                text: plainTextTable));
                                          });
                                          final snackBar = SnackBar(
                                            /// need to set following properties for best effect of awesome_snackbar_content
                                            elevation: 0,
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.transparent,
                                            content: AwesomeSnackbarContent(
                                              title: 'Success',
                                              message: ' Copied to clipboard',

                                              /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
                                              contentType: ContentType.success,
                                            ),
                                          );

                                          ScaffoldMessenger.of(context)
                                            ..hideCurrentSnackBar()
                                            ..showSnackBar(snackBar);
                                        },
                                      ),
                                      SizedBox(
                                        height: 50,
                                        child: CustomButton(
                                          onPressed: () {
                                            context.loaderOverlay.show(
                                              widgetBuilder: (progress) {
                                                return const Center(
                                                    child: SpinKitCubeGrid(
                                                  color: Color.fromARGB(
                                                      255, 90, 95, 228),
                                                  size: 100.0,
                                                ));
                                              },
                                            );
                                            setState(() {
                                              guidindex = 1;
                                              getExam(
                                                  'Give the Marking guide for the Exam above');
                                            });

                                            Clipboard.setData(ClipboardData(
                                                text: _response!));
                                          },
                                          text: 'Marking Guide',
                                          icon: Icons.assignment,
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
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
