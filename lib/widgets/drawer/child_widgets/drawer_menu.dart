import 'package:flutter/material.dart';

class DrawerMenuItem extends StatelessWidget {
  final String title;
  final IconData iconData;
  final VoidCallback? onTapFunction;

  const DrawerMenuItem({
    super.key,
    required this.title,
    required this.iconData,
    this.onTapFunction,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(title),
      onTap: onTapFunction,
    );
  }
}
