import 'package:flutter/material.dart';
import '../tabs/my_agenda/deleted_agenda_tab.dart';

class DeletedAgendaPage extends StatefulWidget {
  static const routeName = '/deleted-agenda-page';

  const DeletedAgendaPage({super.key});

  @override
  State<DeletedAgendaPage> createState() => _DeletedAgendaPageState();
}

class _DeletedAgendaPageState extends State<DeletedAgendaPage> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DeletedAgendaTab(),
    const Placeholder(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
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
