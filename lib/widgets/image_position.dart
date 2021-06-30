import 'package:flutter/material.dart';
import 'package:flutter_chat_ui_starter/animations/fade_animation.dart';

class ImagePosition extends StatelessWidget {
  ImagePosition({this.delay, this.top});
  final double delay;
  final double top;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Positioned(
      top: top,
      left: 0.0,
      child: FadeAnimation(
          delay: delay,
          child: Container(
            width: width,
            height: 400.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/one.png'),
                fit: BoxFit.cover,
              ),
            ),
          )),
    );
  }
}
