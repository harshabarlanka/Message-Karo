// ignore_for_file: avoid_print
import 'package:appdev/chat_bubble.dart';
import 'package:appdev/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final GoogleTranslator translator = GoogleTranslator();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    initializeSpeechToText();
  }

  void _translateMessage() async {
    final originalMessage = _messageController.text;

    try {
      Translation translation = await translator.translate(
        originalMessage,
        from: 'te', // Source language code (Telugu)
        to: 'en', // Target language code (English)
      );

      setState(() {
        _messageController.text = translation.text;
      });
    } catch (e) {
      print('Translation error: $e');
    }
  }

  Future<void> initializeSpeechToText() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {},
      onError: (error) {
        print("Speech recognition error: $error");
      },
    );
    if (available) {
      List<LocaleName> locales = await _speechToText.locales();
      print(locales);
    } else {
      print("Speech recognition not available");
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
    });

    _speechToText.listen(
      onResult: (result) {
        setState(() {
          _messageController.text = result.recognizedWords;
        });
      },
      localeId: 'te_IN',
    );
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
    });

    _speechToText.stop();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.receiverUserEmail),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 3.5),
          child: Column(
            children: [
              Expanded(
                child: _buildMessageList(),
              ),
              const SizedBox(
                height: 4,
              ),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            widget.receiverUserID, _auth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('loading...');
          }
          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == _auth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          crossAxisAlignment: (data['senderId'] == _auth.currentUser!.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderId'] == _auth.currentUser!.uid)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            //Text(data['senderEmail']),
            ChatBubble(message: data['message'])
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.only(left: 13, top: 3.5, bottom: 3.5, right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.blue.shade50,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: (value) {
                setState(() {
                  _isTyping = value.trim().isNotEmpty;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isTyping ? Colors.blue[500] : Colors.blue[200],
              borderRadius: BorderRadius.circular(100),
            ),
            child: IconButton(
              color: Colors.white,
              onPressed: sendMessage,
              icon: const Icon(
                Icons.send,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 40,
            height: 40,
            child: CircleAvatar(
              backgroundColor:
                  _isListening ? Colors.blue[500] : Colors.blue[200],
              radius: 24,
              child: IconButton(
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    if (!_isListening) {
                      _startListening();
                    } else {
                      _stopListening();
                    }
                  });
                },
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isTyping ? Colors.blue[500] : Colors.blue[200],
              borderRadius: BorderRadius.circular(100),
            ),
            child: IconButton(
              color: Colors.white,
              onPressed: _translateMessage,
              icon: const Icon(
                Icons.translate,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
