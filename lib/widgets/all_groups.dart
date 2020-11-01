import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../custom_widgets/margin.dart';
import '../models/firebaseMethods.dart';
import './chat_room.dart';
import 'login.dart';

class AllGroups extends StatefulWidget {
  final FirebaseMethods firebaseMethods;
  final List<Map<String, dynamic>> allGroups;

  AllGroups({Key key, this.firebaseMethods, this.allGroups}) : super(key: key);

  @override
  _AllGroupsState createState() => _AllGroupsState();
}

class _AllGroupsState extends State<AllGroups> {
  int id = 1; //id for radio button
  bool longPressedOnItem = false; //to know if the user has long pressed
  int selectedItemIndex; //the index of long pressed item in list view
  bool joinToNewGroup =
      false; //If user want to add new group the or join to exisiting group value will be true otherwise will be false
  final txtController = TextEditingController();
  bool invalidInput =
      false; //if the data entered is not correct the value will be true otherwise will be false

  void addNewGroup(DocumentReference document) {
    document.set({
      'groupName': txtController.text,
      'members': [widget.firebaseMethods.getCurrentUser().uid]
    }).then((value) => setState(() => joinToNewGroup = false));
    setState(() => widget.allGroups.add({
          'groupId': txtController.text,
          'data': {'groupName': txtController.text}
        }));
  }

  void addToFirebase() async {
    if (txtController.text != '') {
      setState(() => invalidInput = false);
      final document = widget.firebaseMethods.firestore
          .collection('group')
          .doc(txtController.text);
      document.get().then((value) {
        if (value.exists) {
          //if value is in firebase
          if (id == 1) {
            //if join radio button selected
            document.update({
              'members': FieldValue.arrayUnion(
                  [widget.firebaseMethods.getCurrentUser().uid])
            });
            setState(() {
              joinToNewGroup = false;
              widget.allGroups.add({
                'groupId': txtController.text,
                'data': {'groupName': txtController.text}
              });
            });
            txtController.clear();

          } else if (id == 2) //adding new group with id is found before
            setState(() => invalidInput = true);
        } else {
          if (id == 1) {
            //if the entered value not exisit and the user want to join to this group display message to him
            setState(() => invalidInput = true);
          } else if (id == 2) {
            //name not found in firestore and want to create new one
            addNewGroup(document);
            txtController.clear();
          }
        }
      });
    }
  }

  void deleteFromDatabase(int index) {
    widget.firebaseMethods.firestore
        .collection('group')
        .doc(widget.allGroups[index]['data']['groupName'])
        .update({
      'members': FieldValue.arrayRemove([
        widget.firebaseMethods.getCurrentUser().uid,
      ])
    });
    setState(() {
      widget.allGroups.removeAt(index);
      longPressedOnItem = false; //make delete icon disappear
    });
  }

  Widget signOut() {
    return FlatButton.icon(
      icon: Icon(
        Icons.logout,
        color: Colors.white,
      ),
      label: Text('Signout', style: TextStyle(color: Colors.white)),
      onPressed: () {
        widget.firebaseMethods.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Login(widget.firebaseMethods),
          ),
        );
      },
    );
  }

  Widget radioListTile(String text, int index) {
    return Expanded(
      child: RadioListTile(
          title: Text(text),
          value: index,
          groupValue: id,
          onChanged: (value) {
            setState(() => id = index);
          }),
    );
  }

  Widget addNewField() {
    return Column(children: [
      Row(children: [
        radioListTile('Join group', 1),
        radioListTile('Create group', 2),
      ]),
      Margin(
        child: TextField(
          onChanged: (_) {
            if (invalidInput)
              setState(() {
                invalidInput = false;
              });
          },
          controller: txtController,
          decoration: InputDecoration(
            errorText: invalidInput ? 'Invalid input' : null,
            hintText: 'Enter group name...',
            filled: true,
            fillColor: Color.fromARGB(140, 100, 89, 100),
            suffixIcon: RaisedButton.icon(
              icon: Icon(Icons.add),
              label: Text(id == 1 ? 'join' : 'Create'),
              onPressed: () {
                addToFirebase();

              },
            ),
          ),
        ),
      ),
    ]);
  }

  Widget trailingIcon(int index) {
    return longPressedOnItem &&
            selectedItemIndex ==
                index //to determine if the longpressed item is the only one in the list view
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    deleteFromDatabase(index);
                  }),
              IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => setState(() => longPressedOnItem = false)),
            ],
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[100],
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              joinToNewGroup = !joinToNewGroup;
            });
          },
          child: Icon(joinToNewGroup ? Icons.close : Icons.add)),
      appBar: AppBar(
        leading: Container(),
        title: Text('All groups'),
        centerTitle: true,
        actions: [signOut()],
      ),
      body: Column(
        children: [
          if (joinToNewGroup) addNewField(),
          Expanded(
            child: ListView.builder(
              itemCount: widget.allGroups.length,
              itemBuilder: (context, index) {
                String groupId = widget.allGroups[index]['groupId'];
                Map<String, dynamic> data = widget.allGroups[index]['data'];
                return Card(
                  color: Colors.purple[100],
                  child: Margin(
                    child: ListTile(
                      onTap: () {
                        if (!longPressedOnItem) {//if the delete icon not displayed
                        setState(()=>joinToNewGroup=false);
                        txtController.clear();
                       
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChatRoom(groupId,
                                  widget.firebaseMethods, data['groupName'])));
                        }
                      },
                      leading: CircleAvatar(
                        child: Text(data['groupName'][0]),
                      ),
                      title: Margin(
                        child: Text(
                          data['groupName'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      onLongPress: () {
                        selectedItemIndex = index;

                        setState(() => longPressedOnItem = !longPressedOnItem);
                      },
                      trailing: trailingIcon(index),
                    ),
                  ),
                  elevation: 6,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
