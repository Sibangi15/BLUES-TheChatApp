class Message {
  final String senderId;
  final String senderEmail;
  final String recieverID;
  final String message;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.recieverID,
    required this.message,
    required this.timestamp,
  });

  //convert to map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'recieverID': recieverID,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
