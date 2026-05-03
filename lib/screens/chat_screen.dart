import 'package:flutter/material.dart';
import 'package:studysphere/services/ai_service.dart';
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  void sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"user": text});
      isLoading = true;
    });

    controller.clear();

    String reply = await getSmartResponse(text);

    setState(() {
      messages.add({"bot": reply});
      isLoading = false;
    });
  }

  Widget buildMessage(Map<String, String> msg) {
    if (msg.containsKey("user")) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(10),
          color: Colors.green,
          child: Text(msg["user"]!, style: TextStyle(color: Colors.white)),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(10),
          color: Colors.grey.shade300,
          child: Text(msg["bot"]!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("StudySphere AI")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          if (isLoading)
            Padding(
              padding: EdgeInsets.all(8),
              child: Text("AI is typing... 🤖"),
            ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: "Ask something..."),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: sendMessage,
              )
            ],
          )
        ],
      ),
    );
  }
}