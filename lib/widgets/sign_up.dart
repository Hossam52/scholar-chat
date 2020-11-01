import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../custom_widgets/custom_field.dart';
import '../custom_widgets/form_button.dart';
import '../custom_widgets/margin.dart';
import './login.dart';
import '../models/firebaseMethods.dart';

class SignUp extends StatefulWidget {
  final FirebaseMethods firebaseMethods;
  SignUp(this.firebaseMethods);
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final signUpKey = GlobalKey<FormState>();

  bool passwordIdentical = true;

  Map<String, String> data = Map<String, String>();

  bool emailFound = false;

  String errorMessage;

  void goToLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login(widget.firebaseMethods)));
  }

  void addToFirebase(UserCredential credentialUser) {
    widget.firebaseMethods.firestore.collection('users').doc(credentialUser.user.uid).set({
      'name': data['name'],
      'email': data['email'],
    });
    widget.firebaseMethods.firestore.collection('group').doc('public').update(
      {'members': FieldValue.arrayUnion([credentialUser.user.uid])},
    );
  }

  void signUpUser() {
    final temp = widget.firebaseMethods.signUp(data['email'], data['password']);
    temp.then((value) {
      if (value is Exception) {
        print(value.toString());
        setState(() {
          errorMessage = value.toString();
          emailFound = true;
        });
      } else {
        addToFirebase(value);
        goToLogin();
      }
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
          body: Margin(
                      child: Card(
              child: Form(
                key: signUpKey,
                child: Align(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('SignUp',
                            style: Theme.of(context).textTheme.headline4),
                        if (emailFound)
                          Text(errorMessage,
                              style:
                                  TextStyle(color: Theme.of(context).errorColor)),
                        CustomTextField(
                          icon:Icons.person,
                          label: 'Name',
                          validate: (val) {
                            if (val.isEmpty) return 'Name field is required';
                            data['name'] = val;
                            return null;
                          },
                        ),
                        CustomTextField(
                          icon:Icons.email,
                          isEmail: true,
                          label: 'Email',
                          validate: (val) {
                            if (val.isEmpty) return 'Email field is required';
                            data['email'] = val;
                            return null;
                          },
                        ),
                        CustomTextField(
                          icon:Icons.security,
                          obsecureText: true,
                          label: 'Password',
                          validate: (val) {
                            if (val.isEmpty) return 'Password field is required';
                            if(val.length<6) return 'Password should be at least 6 characters';
                            data['password'] = val;
                            return null;
                          },
                        ),
                        CustomTextField(
                          icon:Icons.security,
                          obsecureText: true,
                          label: 'Confirm Password',
                          validate: (val) {
                            if (val.isEmpty)
                              return ' Confirm password field is required';
                            if (data['password'] != null &&
                                data['password'] != val)
                              return 'Two passwords should be identicals';
                            data['confirmPassword'] = val;
                            return null;
                          },
                        ),
                        FormButton(
                          text: 'Sign Up',
                          onPressed: () {
                            setState(() {
                              emailFound = false;
                            });
                            FocusScope.of(context).unfocus();
                            if (signUpKey.currentState.validate()) {
                              signUpUser();
                            }
                          },
                        ),
                        Margin(
                          margin: EdgeInsets.only(right: 10, top: 5),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Having account? ',
                                    style: TextStyle(fontSize: 18)),
                                InkWell(
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 18),
                                  ),
                                  onTap: goToLogin,
                                ),
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
