import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../../screens/agenda/category_agenda_screen.dart';
import '../../screens/agenda/deleted_agenda_screen.dart';
import '../../screens/agenda/month_agenda_screen.dart';
import '../../screens/agenda/overall_agenda_screen.dart';
import '../../screens/agenda/today_agenda_screen.dart';
import '../providers/categories.dart';
import '../screens/auth/auth_screen.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final ScrollController _controller = ScrollController();

  //auxiliary functions
  Future<void> _fetchCategories(BuildContext context) async {
    await Provider.of<Categories>(context, listen: false).fetchCategories();
  }

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
    return ListTile(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        //drawer header
        buildHeader(context),
        const SizedBox(height: 10),

        //drawer items
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
        buildCategoriesTile(context),
        const Divider(),
        buildListTile('Trash', Icons.delete, () {
          Navigator.of(context)
              .pushReplacementNamed(DeletedAgendaScreen.routeName);
        }),
        const Divider(),

        //logout
        buildLogoutTile(context),
      ],
    ));
  }

  Container buildHeader(BuildContext context) {
    return Container(
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
    );
  }

  ExpansionTile buildCategoriesTile(BuildContext context) {
    return ExpansionTile(
        title: const Text(
          "Categories",
          style: TextStyle(fontSize: 20),
        ),
        leading: const Icon(Icons.category),
        childrenPadding: const EdgeInsets.only(left: 60),
        children: [
          FutureBuilder(
            future: _fetchCategories(context),
            builder: (context, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Consumer<Categories>(
                        builder: (context, categories, _) => SizedBox(
                          height: 150,
                          child: Scrollbar(
                            controller: _controller,
                            thumbVisibility: true,
                            thickness: 10,
                            child: ListView.builder(
                              controller: _controller,
                              shrinkWrap: true,
                              itemCount: categories.categoriesList.length,
                              itemBuilder: (context, index) => ListTile(
                                title: Text(
                                  categories.categoriesList[index].name!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                onTap: () {
                                  Navigator.of(context).pushReplacementNamed(
                                      CategoryAgendaScreen.routeName,
                                      arguments: categories
                                          .categoriesList[index].name!);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
          )
        ]);
  }
}
