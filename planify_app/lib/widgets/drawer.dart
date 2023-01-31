import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:planify_app/screens/agenda/deleted_agenda_screen.dart';

import '../../screens/agenda/month_agenda_screen.dart';
import '../../screens/agenda/overall_agenda_screen.dart';
import '../../screens/agenda/today_agenda_screen.dart';
import '../screens/auth/auth_screen.dart';

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
          fontSize: 20,
        ),
      ),
      onTap: () {
        tapHandler();
      },
    );
  }

  Widget buildLogoutTile(BuildContext context) {
    return Expanded(
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
                fontSize: 20,
                color: Colors.black,
              )),
          onTap: () {
            FirebaseAuth.instance.signOut();
            GoogleSignIn().signOut();
            Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
          },
        ),
      ),
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
              fontSize: 30,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        buildListTile('Overall', Icons.calendar_view_week, () {
          Navigator.of(context)
              .pushReplacementNamed(OverallAgendaScreen.routeName);
        }),
        const Divider(),
        buildListTile('Today', Icons.calendar_today, () {
          Navigator.of(context)
              .pushReplacementNamed(TodayAgendaScreen.routeName);
        }),
        const Divider(),
        buildListTile('Month', Icons.calendar_month, () {
          Navigator.of(context)
              .pushReplacementNamed(MonthAgendaScreen.routeName);
        }),
        const Divider(),
        buildListTile('Trash', Icons.delete, () {
          Navigator.of(context)
              .pushReplacementNamed(DeletedAgendaScreen.routeName);
        }),
        //logout
        buildLogoutTile(context),
      ]),
    );
  }
}
