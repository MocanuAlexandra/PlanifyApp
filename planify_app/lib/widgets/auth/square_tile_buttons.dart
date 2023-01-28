import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imapgePath;
  final Function()? onTap;

  const SquareTile({super.key, required this.imapgePath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Image.asset(
            imapgePath,
            height: 40,
          )),
    );
  }
}
