import 'package:flutter/material.dart';

class Margin extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final Widget child;

  const Margin({Key key, this.margin = const EdgeInsets.all(10), this.child})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:margin,
      child: child,
    );
  }
}
