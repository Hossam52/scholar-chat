
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import './widgets/login.dart';
import 'models/firebaseMethods.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
final FirebaseMethods firebaseMethods = FirebaseMethods();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.yellow,
      theme: ThemeData(primaryColor: Colors.deepPurple,backgroundColor: Colors.yellow),

      home: Login(firebaseMethods),
    );
  }
}
