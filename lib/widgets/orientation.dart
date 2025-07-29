import 'package:flutter/material.dart';

Widget getPortrait(child) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: const AssetImage("assets/images/background.jpg"),
          fit: BoxFit.fill,
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.8), BlendMode.dstATop),
        )),
    child: child,
  );
}

Widget getLandscape(child) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
            image: const AssetImage("assets/images/background_land.jpg"),
            fit: BoxFit.fill,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.8), BlendMode.dstATop))
    ),
    child: child,
  );
}
