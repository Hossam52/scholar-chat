import 'package:flutter/foundation.dart';

class MessageModule {
  String text;
  String date;
  String userId;
  bool displayImage;
  String name;

  MessageModule(
      {@required this.text,
      @required this.date,
      @required this.userId,
      this.displayImage = false,
      this.name});
  void display() {
    print('$text$date$userId');
  }
}
