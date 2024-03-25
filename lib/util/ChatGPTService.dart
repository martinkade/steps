import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wandr/util/ChatGPTRequestMessage.dart';

class ChatGPTService {
  final String apiKey;
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';

  ChatGPTService(this.apiKey);

  Future<String> getChatResponse(List<ChatGPTRequestMessage> messages) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(
          {
            'model': "gpt-3.5-turbo",
            'messages': messages.map((e) => {'role': e.role, 'content': e.message}).toList()
          }),
    );

    if (response.statusCode == 200) {
      try {
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
        return decodedResponse['choices'][0]['message']['content'];
      } catch(e) {
        return "";
      }
    } else {
      return "";
    }
  }
}