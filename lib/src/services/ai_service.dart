import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  Future<Map<String, dynamic>?> fetchAIDetails(String goal) async {
    try {
      final API_KEY = dotenv.env['DIFY_API_KEY'];

      final response = await http.post(
        Uri.parse('https://api.dify.ai/v1/chat-messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $API_KEY'
        },
        body: json.encode({
          'query': goal,
          'user': 1,
          'inputs': {'goal': goal}
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final answer = data['answer'];

        final cleanedAnswer =
            answer.replaceAll(RegExp(r'```json|```'), '').trim();

        final answerData = json.decode(cleanedAnswer);
        return answerData;
      } else {
        print('Failed to fetch AI suggestions: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
