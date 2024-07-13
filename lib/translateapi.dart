import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class TextToSpeechAPI {
  final String apiKey = 'AIzaSyB8O-FIy_8UsQOlH5cWBfOXlwF2kZytD8Q';

  Future<String?> synthesizeText(
      String text, String voiceName, String languageCode) async {
    final url = Uri.parse(
        'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'input': {'text': text},
        'voice': {'languageCode': languageCode, 'name': voiceName},
        'audioConfig': {'audioEncoding': 'MP3'},
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['audioContent'];
    } else {
      print('Request failed with status: ${response.statusCode}.');
      print('Response body: ${response.body}');
      return null;
    }
  }
}
