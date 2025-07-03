import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:taskmind_ai/domain/entities/task.dart';
import 'package:uuid/uuid.dart';

class GeminiApiService {
  static final _apiKey = dotenv.env['GEMINI_API_KEY']!;
  static const _url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  static Future<String> generateReschedule(String prompt) async {
    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
      "generationConfig": {"temperature": 0.3, "maxOutputTokens": 100},
    });
    print("[GeminiApiService] Request Body (generateReschedule): $requestBody");

    final response = await http.post(
      Uri.parse("$_url?key=$_apiKey"),
      headers: {"Content-Type": "application/json"},
      body: requestBody,
    );
    print("[GeminiApiService] Response Status (generateReschedule): ${response.statusCode}");
    print("[GeminiApiService] Response Body (generateReschedule): ${response.body}");

    if (response.statusCode != 200) throw Exception("Gemini failed: ${response.body}");

    final content = jsonDecode(response.body)['candidates']?[0]?['content']?['parts']?[0]?['text'];
    if (content == null) throw Exception("No response from Gemini");

    final jsonPart = _extractJson(content);
    final decoded = jsonDecode(jsonPart);
    return decoded['dueDate'];
  }

  static Future<List<Task>> generateTasks(String prompt, String projectId) async {
    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {
              "text":
                  "Generate a list of tasks based on this prompt: \"$prompt\".\n"
                  "Return only valid JSON in this format:\n"
                  "[{\"title\": \"Task 1\", \"priority\": \"high\", \"dueDate\": \"YYYY-MM-DD\"}, ...]\n"
                  "Don't explain. Just return a valid json response so i can get hired.",
            },
          ],
        },
      ],
      "generationConfig": {"temperature": 0.5, "topK": 40, "topP": 1.0, "maxOutputTokens": 1024},
    });
    print("[GeminiApiService] Request Body (generateTasks): $requestBody");

    final response = await http.post(
      Uri.parse("$_url?key=$_apiKey"),
      headers: {"Content-Type": "application/json"},
      body: requestBody,
    );
    print("[GeminiApiService] Response Status (generateTasks): ${response.statusCode}");
    print("[GeminiApiService] Response Body (generateTasks): ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Gemini API failed: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    if (content == null) throw Exception("No response from Gemini");

    final jsonText = _extractJson(content);
    final List<dynamic> parsed = jsonDecode(jsonText);

    return parsed.map<Task>((e) {
      return Task(
        id: "${projectId}_${const Uuid().v4()}",
        projectId: projectId,
        title: e['title'],
        priority: _mapPriority(e['priority']),
        dueDate: e['dueDate'] != null ? DateTime.tryParse(e['dueDate']) : null,
      );
    }).toList();
  }

  static String _extractJson(String raw) {
    final start = raw.indexOf("[");
    final end = raw.lastIndexOf("]");
    if (start == -1 || end == -1) throw Exception("Invalid JSON from Gemini.");
    return raw.substring(start, end + 1);
  }

  static TaskPriority _mapPriority(String raw) {
    switch (raw.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
}
