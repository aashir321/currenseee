import 'package:flutter/material.dart';

Widget createDrawerHeaderUser({required String name, required BuildContext context}) {
  return SizedBox(
    height: 250,
    child: DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      // decoration: const BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage("assets/images/drawer.jpg"),
      //     fit: BoxFit.cover,
      //   ),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              color: Colors.black.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 10.0),
                    // const CircleAvatar(
                    //   radius: 60,
                    //   backgroundColor: Colors.orangeAccent,
                    //   child: CircleAvatar(
                    //     radius: 50,
                    //     backgroundColor: Colors.yellow,
                    //     backgroundImage: AssetImage("assets/images/avatar.jpg"),
                    //   ),
                    // ),
                    const SizedBox(height: 10.0),
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget createDrawerBodyItem({required IconData icon, required String text, required GestureTapCallback onTap}) {
  return ListTile(
    leading: Icon(icon, color: Colors.blue),
    title: Text(text, style: const TextStyle(color: Colors.white)),
    onTap: onTap,
  );
}


