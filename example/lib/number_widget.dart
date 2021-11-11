import 'dart:math';

import 'package:flutter/material.dart';

class NumberWidget extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final int tag;

  const NumberWidget(this.text,
      {Key? key,
      this.color = Colors.black,
      this.textColor = Colors.white,
      this.tag = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: Container(
        alignment: Alignment.center,
        width: 96.0,
        height: 128.0,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 80.0, color: textColor),
            maxLines: 1,
        ),
      ),
    );
  }
}

Color getRandomColor() {
  int a = 255;
  int r = Random().nextInt(255);
  int g = Random().nextInt(255);
  int b = Random().nextInt(255);
  return Color.fromARGB(a, r, g, b);
}


