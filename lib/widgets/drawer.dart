import 'package:flutter/material.dart';
import 'package:currensee/widgets/drawer_layout.dart';

class UserDrawer extends StatefulWidget {
  const UserDrawer({super.key, required this.name});
  final String name;

  @override
  State<UserDrawer> createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[900],
        child: ListView(
          children: <Widget>[
            createDrawerHeaderUser(name: widget.name, context: context),
            createDrawerBodyItem(
              icon: Icons.home,
              text: "Home",
              onTap: () {
                Navigator.pushNamed(context, "/home", arguments: widget.name);
              },
            ),
            createDrawerBodyItem(
              icon: Icons.money,
              text: "Currency List",
              onTap: () {
                Navigator.pushNamed(context, "/currency_list");
              },
            ),
            createDrawerBodyItem(
              icon: Icons.transfer_within_a_station,
              text: "Currency Converter",
              onTap: () {
                Navigator.pushNamed(context, '/currency_converter');
              },
            ),
            createDrawerBodyItem(
              icon: Icons.article,
              text: "Currency News",
              onTap: () {
                Navigator.pushNamed(context, '/currency_news');
              },
            ),
            createDrawerBodyItem(
              icon: Icons.door_back_door,
              text: "Logout",
              onTap: () {
                Navigator.pushReplacementNamed(context, "/");
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('App Ver 1.0.0',
                  style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
