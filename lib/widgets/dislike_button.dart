import 'package:flutter/material.dart';

class DislikeButton extends StatelessWidget {
  final Function onTap;
  final double size;

  const DislikeButton({required this.onTap, this.size = 30.0, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Icon(Icons.thumb_down, size: size, color: Colors.blueGrey),
    );
  }
}
