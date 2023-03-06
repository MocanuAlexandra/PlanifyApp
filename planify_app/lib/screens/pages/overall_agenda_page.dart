import 'package:flutter/material.dart';
import '../tabs/my_agenda/overall_agenda_tab.dart';
import '../tabs/shared_agenda/shared_overrall_agenda_tab.dart';

class OverallAgendaPage extends StatefulWidget {
  static const routeName = '/overall-agenda-page';

  const OverallAgendaPage({super.key});

  @override
  State<OverallAgendaPage> createState() => _OverallAgendaPageState();
}

class _OverallAgendaPageState extends State<OverallAgendaPage> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const OverallAgendaTab(),
    const SharedOverallAgendaTab(),
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
