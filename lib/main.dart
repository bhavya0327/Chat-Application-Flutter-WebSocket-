import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'chat_bubble.dart';
import 'message_input.dart';
import 'user_avatar.dart';
import 'package:intl/intl.dart';  // Importing DateFormat

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController(); // Added password controller
  String _selectedAvatar = 'avatar1.png';
  String _username = '';
  String _password = '';  // Store the password
  final List<Map<String, String>> _avatars = [
    {'image': 'avatar1.png', 'name': 'Whisker Wizard'},
    {'image': 'avatar2.png', 'name': 'Sushi Samurai'},
    {'image': 'avatar3.png', 'name': 'Chuckle Monster'},
    {'image': 'avatar4.png', 'name': 'The Meme Master'},
  ];

  _saveUserData(String username, String avatar, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('avatar', avatar);
    await prefs.setString('password', password);  // Save password
  }

  _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
      _selectedAvatar = prefs.getString('avatar') ?? 'avatar1.png';
      _password = prefs.getString('password') ?? '';
      _usernameController.text = _username;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _login() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter a username and password.");
      return;
    }

    _saveUserData(username, _selectedAvatar, password);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(username: username, avatar: _selectedAvatar),
      ),
    );
  }

  _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Chat App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade300,
                  backgroundImage: AssetImage('assets/images/$_selectedAvatar'),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedAvatar,
                  dropdownColor: Colors.blue.shade700,  // Dark background for the dropdown
                  style: TextStyle(color: Colors.white),  // White text for dropdown items
                  items: _avatars.map((avatar) {
                    return DropdownMenuItem(
                      value: avatar['image']!,
                      child: Row(
                        children: [
                          Image.asset('assets/images/${avatar['image']!}', width: 30, height: 30),
                          SizedBox(width: 10),
                          Text(avatar['name']!),  // Display character names instead of image names
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAvatar = value!;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Enter your username',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true, // To mask the password
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Enter your password',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.blue.shade600, // Darker button color
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String username;
  final String avatar;

  ChatScreen({required this.username, required this.avatar});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> messages = [];
  ScrollController _scrollController = ScrollController();
  late WebSocketChannel _channel;

  void sendMessage(String message) {
    if (message.isEmpty) return;

    _channel.sink.add(jsonEncode({
      'username': widget.username,
      'message': message,
    }));

    setState(() {
      messages.add({'sender': widget.username, 'message': message});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse(kIsWeb ? 'ws://localhost:8080' : 'ws://10.0.2.2:8080'),
    );

    _channel.stream.listen((message) {
      try {
        final decodedMessage = jsonDecode(message);
        setState(() {
          messages.add({'sender': decodedMessage['username'], 'message': decodedMessage['message']});
        });
        _scrollToBottom();
      } catch (e) {
        print("Error decoding message: $e");
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isSentByUser = messages[index]['sender'] == widget.username;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: isSentByUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isSentByUser)
                        UserAvatar(
                          avatarUrl: 'assets/images/avatar2.png',
                          initials: 'A', // Replace with the sender's initials
                          radius: 20,  // Provide radius
                        ),
                      ChatBubble(
                        message: messages[index]['message']!,
                        isSentByUser: isSentByUser,
                        avatar: widget.avatar,
                        timestamp: DateFormat('hh:mm a').format(DateTime.now()), // Format the timestamp
                      ),
                      if (isSentByUser)
                        UserAvatar(
                          avatarUrl: 'assets/images/${widget.avatar}',
                          initials: widget.username.isNotEmpty ? widget.username[0].toUpperCase() : '',
                          radius: 20, // Provide radius
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          MessageInput(
            controller: _messageController,
            onSendPressed: () {
              sendMessage(_messageController.text);
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }
}
