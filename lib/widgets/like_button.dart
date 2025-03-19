import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final Function onTap;
  final double size;

  const LikeButton({required this.onTap, this.size = 30.0, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Icon(Icons.thumb_up, size: size, color: Colors.white),
    );
  }
}
