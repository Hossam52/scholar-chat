import 'package:flutter/material.dart';

import './margin.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String password;
  final bool obsecureText;
  final Function validate;
  final Function onSaved;
  final bool isEmail;
  final IconData icon;

  const CustomTextField(
      {Key key,
      this.label,
      this.password,
      this.obsecureText = false,
      this.validate,
      this.onSaved,
      this.isEmail = false, this.icon})
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool displayPassword = false;
  Widget icon = Icon(Icons.visibility_off);

  Widget showPassword() {
    return GestureDetector(
        child: icon,
        onLongPressStart: (_) {
          setState(() {
            displayPassword = true;
            icon = Icon(Icons.visibility);
          });
        },
        onLongPressEnd: (_) {
          setState(() {
            displayPassword = false;
            icon = Icon(Icons.visibility_off);
          });
        });
  }

  bool hidePassword() {
    if (widget.obsecureText) {
      if (displayPassword)
        return false;
      else
        return true;
    } 
    else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    return Margin(
      child: TextFormField(
        
        validator: widget.validate,
        onSaved: widget.onSaved,
        obscureText: hidePassword(),
        keyboardType: widget.isEmail ? TextInputType.emailAddress : null,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon),
            fillColor: Colors.purple[100],
            labelText: widget.label,
            filled: true,
            suffix: widget.obsecureText ? showPassword() : null),
      ),
    );
  }
}
