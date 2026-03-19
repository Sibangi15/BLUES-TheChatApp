import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_chatapp/models/message.dart';
import 'package:firebase_storage/firebase_storage.dart';
//import 'dart:io';
import 'dart:typed_data';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        //go through each individual
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // send message
  Future<void> sendMessage(String recieverID, String message) async {
    //get current user
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create new message
    Message newMessage = Message(
      senderId: currentUserID,
      senderEmail: currentUserEmail,
      recieverID: recieverID,
      message: message,
      timestamp: timestamp.toDate(),
    );

    //construct chatroom id for the two users
    List<String> ids = [currentUserID, recieverID];
    ids.sort();
    String chatRoomId = ids.join('_');

    //add message to database
    await _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .add(newMessage.toMap());
  }

  // get message
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    //construct chatroom id for the two users
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // upload image
  Future<String> uploadImageWeb(Uint8List bytes) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final ref = FirebaseStorage.instance.ref().child("chat_images/$fileName");

      await ref.putData(bytes);

      return await ref.getDownloadURL();
    } catch (e) {
      print("UPLOAD ERROR: $e");
      rethrow;
    }
  }

  //send image message
  Future<void> sendImageMessage(String receiverId, String imageUrl) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // construct chatroom id
    List<String> ids = [currentUserID, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .add({
          "senderId": currentUserID,
          "senderEmail": currentUserEmail,
          "recieverID": receiverId,
          "message": "",
          "imageUrl": imageUrl,
          "timestamp": timestamp,
        });
  }

  //delete message
  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    await _firestore
        .collection('ChatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .doc(messageId)
        .delete();
  }
}