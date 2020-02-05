import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // final _firestore = Firestore.instance;
  //creating a firestore instance for the message
  final messageTextController = TextEditingController();
  // creating a controller to help clear the message from
  //the text area after sending
  final _auth = FirebaseAuth.instance;
  // creating a firebase instance
  
  String messageText;
   //creating a variable to contain the message to be sent

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    //getting the current user when the state is initialized
  }

  void getCurrentUser() async {
    try {
    final user = await _auth.currentUser();
    if (user != null) {
      loggedInUser = user;
    }
  } catch (e) {
      print (e);
    }
  }

  // void getMessages() async {
  //   final messages = await _firestore.collection('messages').getDocuments();
  //   for (var message in messages.documents){
  //     print(message.data);
  //   }
  // }
  // Creating a method to tap into the message on the database
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      // to help clear the message after sending it
                      onChanged: (value) {
                        messageText = value;
                        //setting the value of the message
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      _firestore.collection('messages').add({
                        //tapping into the firebase collection
                        'text': messageText,
                        'sender': loggedInUser.email
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
              // this to show the data on the screen
              stream:_firestore.collection('messages').snapshots(),
              builder: (context, snapshot){
                if (snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                  final messages = snapshot.data.documents.reversed;
                  //entering into the stream of snapshots, 
                  //checking the data in the snapshots and retrieving the data there
                  List<MessageBubble> messageBubbles = [];
                  for (var message in messages) {
                    final messageText = message.data['text'];
                    final messageSender = message.data['sender'];

                    final currentUser = loggedInUser.email;

                    final messageBubble = MessageBubble(
                      sender: messageSender, 
                      text: messageText,
                      isMe: currentUser == messageSender,
                      );

                    messageBubbles.add(messageBubble);
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      children: messageBubbles,
                    ),
                  );
                
              },
            );
  }
}

class MessageBubble extends StatelessWidget {

  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        // if i didn't send the message, align it to the left
        children: <Widget>[
          Text(sender, style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54
          ),),
          Material(
            borderRadius: isMe ? BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30), 
              bottomRight: Radius.circular(30),
              topRight: Radius.circular(30))
            : BorderRadius.only(
              topLeft: Radius.circular(0), 
              bottomLeft: Radius.circular(30), 
              bottomRight: Radius.circular(30)),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            //if i wasn't the one who sent the message, set color to white
            child: Padding(
              padding:EdgeInsets.symmetric(horizontal:20, vertical: 10 ),
              child: Text(
                text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black54,
                    // if i didn't send the message, let the text color = black54
                    fontSize: 15.0,
                  ),
                ),
            ),
          ),
        ],
      ),
    ); 
  }
}