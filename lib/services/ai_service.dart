import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiKey = "YOUR_API_KEY";

// 🌐 REAL GEMINI AI
Future<String> askGemini(String message) async {
  final url = Uri.parse(
    "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$apiKey",
  );

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": message}
          ]
        }
      ]
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["candidates"][0]["content"]["parts"][0]["text"];
  } else {
    throw Exception("Gemini error");
  }
}

// 🧪 MOCK AI
String getMockResponse(String input) {
  input = input.toLowerCase();

  if (input.contains("hello")) {
    return "Hello 👋 I am StudySphere AI assistant";
  }

  return "I can help you with your studies 📚";

}

// 🔥 SMART SYSTEM
Future<String> getSmartResponse(String input) async {
  try {
    return await askGemini(input);
  } catch (e) {
    return getMockResponse(input);
  }
}