import 'package:flutter/material.dart';

class CountLabel extends StatelessWidget {
  final String? count;
  final String label;
  final VoidCallback? onTap;

  const CountLabel({
    Key? key,
    required this.count,
    required this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Text(
            count ?? '0',
            style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 10.5)),
        ],
      ),
    );
  }
}
