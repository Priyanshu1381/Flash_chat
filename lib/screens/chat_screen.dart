import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
late final logginedUser;

class ChatScreen extends StatefulWidget {
  static const String id='chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore=FirebaseFirestore.instance;
  final messageTextControler=TextEditingController();
  final _auth=FirebaseAuth.instance;
  late final logginedUser;
  late String messagetext='hello';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentuser();
  }

  void getCurrentuser() async{
    final user=await _auth.currentUser;
    if(user!=null){
      logginedUser=user;
      print(logginedUser.email);
    }
  }
  void messageStream()async{
    await for(var snapshot in _firestore.collection('messages').snapshots()){
      for( var message in snapshot.docs){
        print(message.data());

      }
    }
  }
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
                //Implement logout functionality
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
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                final messages = snapshot.data?.docs.reversed;
                List<MessageBubble> messageWidgets = [];
                for (var message in messages!) {
                  var data = message.data() as Map;
                  final messageText = data['text'];
                  final messageSender = data['Field'];
                  final currentuser=logginedUser.email;

                  final messageWidget = MessageBubble(field: messageSender,text: messageText,isme: currentuser==messageSender,);
                  messageWidgets.add(messageWidget);
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 15.0),
                    children: messageWidgets,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextControler,
                      onChanged: (value) {
                        messagetext=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton (
                    onPressed: () {
                      messageTextControler.clear();
                      _firestore.collection('messages').add({
                        'text':messagetext,
                        'Field':logginedUser.email,
                      });
                      //Implement send functionality.
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

class MessageBubble extends StatelessWidget {

  MessageBubble({required this.field,required this.text,required this.isme});
  late final String field;
  late final String text;
  final bool isme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isme?CrossAxisAlignment.end:CrossAxisAlignment.start,
        children:<Widget> [
          Text(field,style: TextStyle(
            fontSize: 12.0,
            color: Colors.black54,
          ),),
         Material(
          borderRadius: isme?BorderRadius.only(topLeft:Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0),):BorderRadius.only(topRight:Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0),),
          elevation: 5.0,
          color: isme?Colors.lightBlueAccent:Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
            child: Text('$text',
              style:TextStyle(
                color: isme?Colors.white:Colors.lightBlueAccent,
                fontSize: 17.0,
              ) ,),
          ),
        ),
     ]
      ),
    );
  }
}
