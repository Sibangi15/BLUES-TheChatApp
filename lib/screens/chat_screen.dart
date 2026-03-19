import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_chatapp/components/chat_bubble.dart';
import 'package:my_chatapp/components/my_textfield.dart';
import 'package:my_chatapp/services/auth/auth_service.dart';
import 'package:my_chatapp/services/chat/chat_services.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String recieverEmail;
  final String recieverID;
  ChatPage({super.key, required this.recieverEmail, required this.recieverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //text controller
  final TextEditingController _messageController = TextEditingController();

  //chat and auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  //for textified focus
  FocusNode focusNode = FocusNode();

  //pick image from gallery
  Future<XFile?> pickImage() async {
    return await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
  }

  void sendImageMessage() async {
    final image = await pickImage();
    if (image == null) return;
    final bytes = await image.readAsBytes();
    String imageUrl = await _chatService.uploadImageWeb(bytes);
    await _chatService.sendImageMessage(widget.recieverID, imageUrl);
    scrollDown();
  }

  String getChatRoomId() {
    String currentUserID = _authService.getCurrentUser()!.uid;
    List<String> ids = [currentUserID, widget.recieverID];
    ids.sort();
    return ids.join('_');
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        //scroll to bottom when keyboard opens
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    //scroll to bottom when messages are loaded
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    focusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  //send Message
  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatService.sendMessage(
        widget.recieverID,
        _messageController.text.trim(),
      );
      _messageController.clear();
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recieverEmail),
        backgroundColor: Colors.indigo.shade400,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderId = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.recieverID, senderId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching messages'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is current user
    bool isCurrentUser = data['senderId'] == _authService.getCurrentUser()!.uid;

    //align message to right if current user, else to left
    var alignment = isCurrentUser
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"] ?? "",
            imageUrl: data["imageUrl"] ?? "",
            isCurrentUser: isCurrentUser,
            onDelete: () {
              String chatRoomId = getChatRoomId();
              _chatService.deleteMessage(chatRoomId, doc.id);
            },
          ),
        ],
      ),
    );
  }

  //build user input field
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: sendImageMessage,
          ),
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: 'Type a message',
              obscureText: false,
              focusNode: focusNode,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}