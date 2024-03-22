import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Check the width of the screen to determine the size of the navigation bar
        bool isSmallScreen = constraints.maxWidth < 500;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Jamii Bora',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Handle search functionality
                  print('Search button pressed');
                },
              ),
            ],
            backgroundColor: Colors.green, // Set your desired accent color here
          ),
          drawer: Drawer(
            //Adjust the width for smaller screens
            //Reduce width for smaller screens
            width:
                isSmallScreen ? MediaQuery.of(context).size.width * 0.4 : null,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        backgroundColor: Colors.blue),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: isSmallScreen ? null : const Text('Home'),
                  onTap: () {
                    // Handle navigation to home
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: isSmallScreen ? null : const Text('Favorites'),
                  onTap: () {
                    // Handle navigation to favorites
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: isSmallScreen ? null : const Text('Settings'),
                  onTap: () {
                    // Handle navigation to settings
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: isSmallScreen ? null : const Text('Profile'),
                  onTap: () {
                    // Handle navigation to profile
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          body: Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello Dunia!',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  MyButton(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MyButton extends StatelessWidget {
  const MyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hello Customer!'),
            content: const Text('Thank you for engaging with us!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'),
              ),
            ],
          ),
        );
      },
      child: Container(
        height: 60,
        width: 100,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.lightGreen[500],
        ),
        child: const Center(
          child: Text('Engage'),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isFromBot;

  ChatMessage({required this.message, required this.isFromBot});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(child: Text(message.isFromBot ? "B" : "U")),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(message.isFromBot ? "Bot" : "User",
                    style: Theme.of(context).textTheme.titleMedium),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(message.message),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];

  void _handleSubmitted(String text) async {
    _textController.clear();
    // Here you handle message sent by user here
    setState(() {
      _messages.insert(0, ChatMessage(message: text, isFromBot: false));
    });
    final botMessage = await sendToGeminiAPI(text);
    setState(() {
      _messages.insert(0, ChatMessage(message: botMessage, isFromBot: true));
    });
  }

  Future<String> sendToGeminiAPI(String message) async {
    final String apiKey = dotenv.env['GEMINI_API_KEY']!;
    final String baseUrl = dotenv.env['GEMINI_API_BASE_URL']!;
    final String apiUrl = '$baseUrl/v1/chat';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(<String, String>{
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      return jsonDecode(response.body)['botMessage'];
    } else {
      // If server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load bot message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Screen')),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) =>
                  ChatMessageWidget(message: _messages[index]),
              itemCount: _messages.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child:
                _buildTextComposer(context, _textController, _handleSubmitted),
          ),
        ],
      ),
    );
  }
}

Widget _buildTextComposer(BuildContext context,
    TextEditingController textController, Function(String) handleSubmitted) {
  return IconTheme(
    data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: textController,
              onSubmitted: handleSubmitted,
              decoration:
                  const InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => handleSubmitted(textController.text),
            ),
          ),
        ],
      ),
    ),
  );
}

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(MaterialApp(
    title: 'My app',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.lightGreen), // Set your desired accent color here
    ),
    home: const MyScaffold(),
  ));
}
