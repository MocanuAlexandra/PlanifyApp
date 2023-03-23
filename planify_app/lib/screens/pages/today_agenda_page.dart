import 'package:flutter/material.dart';

import '../tabs_in_pages/my_agenda/today_agenda_tab.dart';
import '../tabs_in_pages/shared_agenda/shared_today_agenda_tab.dart';

class TodayAgendaPage extends StatefulWidget {
  static const routeName = '/today-agenda-page';

  const TodayAgendaPage({super.key});

  @override
  State<TodayAgendaPage> createState() => _TodayAgendaPageState();
}

class _TodayAgendaPageState extends State<TodayAgendaPage> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const TodayAgendaTab(),
    const SharedTodayAgendaTab(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Shared Tasks',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.white.withOpacity(0.5),
        onTap: _onTabTapped,
      ),
    );
  }
}
