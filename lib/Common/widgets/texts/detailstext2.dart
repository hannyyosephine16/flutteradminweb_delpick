import 'package:flutter/material.dart';


class Text2 extends StatelessWidget {
  final String text2;
  final Color color;
  const Text2({
    super.key, required this.text2,
      this.color=Colors.grey
  });

  @override
  Widget build(BuildContext context) {
    return Text(text2,style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color

    ),
    );
  }
}