import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  Widget buildListTile(String title, IconData icon, Function tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Anton',
          fontSize: 20,
        ),
      ),
      onTap: () {
        tapHandler();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        Container(
          height: 120,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerLeft,
          color: Theme.of(context).colorScheme.secondary,
          child: const Text(
            'Planify App',
            style: TextStyle(
              fontFamily: 'Anton',
              fontSize: 30,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        buildListTile('Overall', Icons.calendar_view_week, () {
          Navigator.of(context).pushReplacementNamed('/overall-agenda');
        }),
        const Divider(),
        buildListTile('Today', Icons.calendar_today, () {
          Navigator.of(context).pushReplacementNamed('/today-agenda');
        }),
         const Divider(),
        buildListTile('Month', Icons.calendar_month, () {
          Navigator.of(context).pushReplacementNamed('/month-agenda');
        }),
        const Divider(),
        Expanded(
          child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: ListTile(
              hoverColor: Colors.blue,
              dense: true,
              visualDensity: const VisualDensity(vertical: -4),
              leading: const Icon(
                Icons.logout,
              ),
              title: const Text('Logout',
                  style: TextStyle(
                    fontFamily: 'Anton',
                    fontSize: 20,
                    color: Colors.black,
                  )),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ),
        ),
      ]),
    );
  }
}
