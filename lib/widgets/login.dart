import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../custom_widgets/margin.dart';
import '../custom_widgets/custom_field.dart';
import '../custom_widgets/form_button.dart';
import './all_groups.dart';
import '../models/firebaseMethods.dart';
import './sign_up.dart';

class Login extends StatefulWidget {
  final FirebaseMethods firebaseMethods;
  Login(this.firebaseMethods);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final loginKey = GlobalKey<FormState>();

  final pageController = PageController(initialPage: 0);

  bool dataIsCorrect = true;

  final Map<String, String> signInData = Map<String, String>();

  Future<List<Map<String, dynamic>>> userGroups() async {
    List<Map<String, dynamic>> groups = [];
    await widget.firebaseMethods.firestore.collection('group').get().then(
          (QuerySnapshot snapshot) => snapshot.docs.forEach(
            (element) {
              element
                      .data()['members']
                      .contains(widget.firebaseMethods.getCurrentUser().uid)
                  ? groups.add({'groupId': element.id, 'data': element.data()})
                  : null;
            },
          ),
        );
    return groups;
  }

  Widget signUp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Don\'t have account ', style: TextStyle(fontSize: 18)),
        InkWell(
          child: Text(
            'Sign up',
            style: TextStyle(color: Colors.blue, fontSize: 18),
          ),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SignUp(widget.firebaseMethods),
              ),
            );
          },
        ),
      ],
    );
  }

  void trySignIn() {
    widget.firebaseMethods
        .signIn(signInData['email'], signInData['password'])
        .then((value) {
      if (value != 'Error') {
        userGroups().then(
          (value) {
            print(value);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllGroups(
                    allGroups: value, firebaseMethods: widget.firebaseMethods),
              ),
            );
          },
        );
      } else
        setState(() {
          dataIsCorrect = false;//All data is entered correctly
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.red[100],
          body: PageView(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            children: [
              Center(child: Image.asset('assets/images/logo.jpg')),
              Margin(
                child: Form(
                  key: loginKey,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Login ',
                            style: Theme.of(context).textTheme.headline3,
                          ),
                          if (!dataIsCorrect)
                            Text('Email or password not correct',
                                style: TextStyle(
                                    color: Theme.of(context).errorColor)),
                          CustomTextField(
                            icon: Icons.email,
                            isEmail: true,
                            label: 'Email',
                            validate: (val) {
                              if (val.isEmpty) return 'Email field is required';
                              signInData['email'] = val;
                              return null;
                            },
                          ),
                          CustomTextField(
                            icon: Icons.security_outlined,
                            label: 'Password',
                            obsecureText: true,
                            validate: (val) {
                              if (val.isEmpty)
                                return 'Password field is required';
                              signInData['password'] = val;
                              return null;
                            },
                          ),
                          FormButton(
                            text: 'Log in',
                            onPressed: () {
                              setState(() {
                                dataIsCorrect = true;
                              });
                              FocusScope.of(context).unfocus();
                              if (loginKey.currentState.validate()) {
                                trySignIn();
                              }
                            },
                          ),
                          signUp(),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
