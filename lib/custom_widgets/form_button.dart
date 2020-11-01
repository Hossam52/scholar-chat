import 'package:flutter/material.dart';
 import '../custom_widgets/margin.dart';
class FormButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  

  const FormButton({Key key, this.text, this.onPressed}) : super(key: key);@override
  Widget build(BuildContext context) {
    return Margin(
          child: Container(
            
        width: double.infinity,
        //decoration: BoxDecoration(border: Border.all(color: Colors.black)), //BorderRadius.circular(10)),
        child: RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation:6,
          color: Colors.pink,
          child: Text(text,style:TextStyle(color:Colors.white,fontSize:42)),
          onPressed:onPressed
        ),
      ),
    );
  }
}
