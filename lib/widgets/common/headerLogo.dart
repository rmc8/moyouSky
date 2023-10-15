import 'package:flutter/material.dart';
import 'package:moyousky/utils/constants.dart';

class HeaderLogo extends StatelessWidget {
  final String title;

  HeaderLogo({super.key, this.title = 'moyouSky'});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/icon/moyouSkyIconSmall.png', width: 36.5, height: 36.5),
        Padding(
          padding: const EdgeInsets.only(left: 6.5),
          child: Text(title, style: const TextStyle(color: Color.fromARGB(255, 88, 88, 88),fontFamily: DEFAULT_FONT, fontWeight: FontWeight.bold,)),
        ),
      ],
    );
  }
}
