import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../custom_widgets/margin.dart';
import './chat_stream.dart';
import '../models/firebaseMethods.dart';

class ChatRoom extends StatefulWidget {
  final String chatId;
  final FirebaseMethods firebaseMethods;
  final String name;
  ChatRoom(this.chatId, this.firebaseMethods, this.name);
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final textController = TextEditingController();
  final txtController = TextEditingController();
  bool showAddingText = false; //if true will show textbox to add new friend
  bool invalidInput = false; //if true the data entered is not valid

  String name;
  String userId;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { currentName().then((value) => name = value);});
    //print(name);
    userId = widget.firebaseMethods.getCurrentUser().uid;
  }

  Future<String> currentName() async {
    String value='123';
     await (widget.firebaseMethods.firestore
        .collection('users')
        .get()
        .then(
          (QuerySnapshot snapshot) => snapshot.docs.forEach(
            (element) {
              element.data()['email'].toLowerCase() ==
                      widget.firebaseMethods.getCurrentUser().email
                  ? value = element.data()['name']
                  : null;
            },
          ),
        ));
        return value;
  }
  void sendDataToFirebase() {
    widget.firebaseMethods.firestore
        .collection('messages')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'sentBy': widget.firebaseMethods.firebaseAuth.currentUser.uid,
      'sentAt': DateTime.now().toString(),
      'messageText': textController.text,
      'name': name
    });
  }

  Widget sendBar() {
    return Margin(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLines: 3,
              minLines: 1,
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Enter message ....',
                filled: true,
                fillColor: Colors.grey[400],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.red, size: 36),
            onPressed: () {
              if (textController.text != '') {
                sendDataToFirebase();
                textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void addNewFriend() async {
    if (txtController.text != '') {
      final doc = widget.firebaseMethods.firestore.collection('users');
      String id;
      await doc
          .where('email', isEqualTo: txtController.text)
          .get()
          .then((value) => value.docs.length != 0
              ? value.docs.forEach((element) {
                  invalidInput = false;
                  id = element.id;
                })
              : invalidInput = true);
      if (!invalidInput) {
        widget.firebaseMethods.firestore
            .collection('group')
            .doc(widget.chatId)
            .update({
          'members': FieldValue.arrayUnion([id])
        });
        txtController.clear();
        setState(() {
          showAddingText = false;
        });
      } else
        setState(() => invalidInput);
    }
  }

  Widget addNewField() {
    return Margin(
      child: TextField(
        onChanged: (_) {
          if (invalidInput)
            setState(() {
              invalidInput = false;
            });
        },
        controller: txtController,
        decoration: InputDecoration(
          errorText: invalidInput ? 'This user doesn\'t exisit' : null,
          hintText: 'Enter Email to add new...',
          filled: true,
          fillColor: Color.fromARGB(140, 100, 89, 100),
          suffixIcon: RaisedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add'),
            onPressed: () {
              addNewFriend();
              //addToFirebase();
            },
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    print(name);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: Colors.red[100],
          appBar: AppBar(
            title: Text(widget.name),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(showAddingText ? Icons.close : Icons.add),
                onPressed: () {
                  setState(() => showAddingText = !showAddingText);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              if (showAddingText) addNewField(),
              ChatStream(
                firebaseMethods: widget.firebaseMethods,
                chatId: widget.chatId,
                currentId: userId,
              ),
              sendBar(),
            ],
          )),
    );
  }
}
