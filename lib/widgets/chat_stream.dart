import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/message.dart';
import '../custom_widgets/margin.dart';
import '../models/firebaseMethods.dart';

class ChatStream extends StatefulWidget {
  final String chatId;
  final FirebaseMethods firebaseMethods;
  final String currentId;
  ChatStream({Key key, this.chatId, this.firebaseMethods, this.currentId})
      : super(key: key);

  @override
  _ChatStreamState createState() => _ChatStreamState();
}

class _ChatStreamState extends State<ChatStream> {
  ScrollController controller;
  @override
  initState() {
    super.initState();
  }

  String formatTime(DateTime date) {
    DateFormat formatter = DateFormat('dd/MMM hh:mm');
    return formatter.format(date);
  }

  Widget _time(String date, BuildContext context) {
    return Center(
      child: Text(formatTime(DateTime.parse(date)),
          style: Theme.of(context).textTheme.subtitle2),
    );
  }

  Widget createCircleAvatar(MessageModule message) {
    if (message.displayImage)
      return Column(
        children: [
          Text(message.name),
          CircleAvatar(child: Text(message.name[0])),
        ],
      );
    else
      return CircleAvatar(
        backgroundColor: Colors.transparent,
      );
  }

  Widget _buildMessages(MessageModule messageModule, BuildContext context) {
    return Row(
      mainAxisAlignment: widget.currentId == messageModule.userId
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: widget.currentId == messageModule.userId
          ? [
              Expanded(child: _time(messageModule.date, context)),
              message(messageModule, context)
            ]
          : [
              createCircleAvatar(messageModule),
              message(messageModule, context),
              Expanded(child: _time(messageModule.date, context)),
            ],
    );
  }

  Widget message(MessageModule messageModule, BuildContext context) {
    return Margin(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        child: Container(
            decoration: BoxDecoration(
              color: widget.currentId == messageModule.userId
                  ? Colors.blue[300]
                  : Colors.grey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(
                    widget.currentId == messageModule.userId ? 0 : 10),
                bottomLeft: Radius.circular(
                    widget.currentId == messageModule.userId ? 10 : 0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(messageModule.text, style: TextStyle(fontSize: 17)),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.firebaseMethods.firestore
          .collection('messages')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('sentAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final QuerySnapshot messages = snapshot.data;
          List<MessageModule> messageWidgets = [];
          for (int index = 0; index < messages.docs.length; index++) {
            Map<String, dynamic> data = messages.docs[index].data();
            bool displayImage = false;

            if (data['sentBy'] != widget.firebaseMethods.getCurrentUser().uid)
              displayImage = true;

            messageWidgets.add(MessageModule(
                text: data['messageText'],
                date: data['sentAt'],
                userId: data['sentBy'],
                name: data['name'],
                displayImage: displayImage));
          }
          return Expanded(
            child: ListView.builder(
              itemCount: messageWidgets.length,
              itemBuilder: (_, index) {
                return _buildMessages(messageWidgets[index], context);
              },
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            ),
          );
        } else
          return Center(child: Text('No messages yet'));
      },
    );
  }
}
