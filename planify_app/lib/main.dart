import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/pages/deleted_agenda_page.dart';
import 'screens/pages/month_agenda_page.dart';
import 'screens/pages/overall_agenda_page.dart';
import 'screens/pages/today_agenda_page.dart';
import 'providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/task_provider.dart';
import '../../providers/task_reminder_provider.dart';
import 'screens/tabs/my_agenda/deleted_agenda_tab.dart';
import 'screens/tabs/my_agenda/month_agenda_tab.dart';
import 'screens/tabs/my_agenda/overall_agenda_tab.dart';
import 'screens/tabs/my_agenda/category_agenda_tab.dart';
import 'screens/tabs/my_agenda/today_agenda_tab.dart';
import '../../screens/auth/auth_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/task/add_edit_task_category_screen.dart';
import '../../screens/task/add_edit_task_screen.dart';
import '../../screens/task/task_details_screen.dart';
import '../../services/location_based_notification_service.dart';
import '../../services/notification_service.dart';
import 'firebase_options.dart';
import 'providers/task_category_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic> _filters = {
    'locationBasedNotification': false,
    'intervalOfNotification': null,
  };

  void initFilters() async {
    // get filters from shared preferences
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? filtersJson = pref.getString('filters');
    if (filtersJson != null) {
      setState(() {
        _filters = json.decode(filtersJson);
      });
    }
  }

  Future<void> saveFiltersInSP(Map<String, dynamic> filterData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('filters', json.encode(filterData));
  }

  @override
  void initState() {
    initFilters();
    NotificationService.setListeners(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => TaskProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => TaskCategoryProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => TaskReminderProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserProvider(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Planify App',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color.fromARGB(255, 156, 39, 176),
              secondary: const Color.fromARGB(255, 19, 208, 164),
            ),
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (userSnapshot.hasData) {
                return const OverallAgendaPage();
              } else {
                return const AuthScreen();
              }
            },
          ),
          routes: {
            OverallAgendaPage.routeName: (context) => const OverallAgendaPage(),
            OverallAgendaTab.routeName: (context) => const OverallAgendaTab(),

            TodayAgendaPage.routeName: (context) => const TodayAgendaPage(),
            TodayAgendaTab.routeName: (context) => const TodayAgendaTab(),

            MonthAgendaPage.routeName: (context) => const MonthAgendaPage(),
            MonthAgendaTab.routeName: (context) => const MonthAgendaTab(),

            DeletedAgendaPage.routeName: (context) => const DeletedAgendaPage(),
            DeletedAgendaTab.routeName: (context) => const DeletedAgendaTab(),

            //TODO  CategoryAgendaPage.routeName: (context) => const CategoryAgendaPage(),
            CategoryAgendaTab.routeName: (context) => const CategoryAgendaTab(),

            AddEditTaskScreen.routeName: (context) => const AddEditTaskScreen(),
            TaskDetailsScreen.routeName: (context) => const TaskDetailsScreen(),
            AuthScreen.routeName: (context) => const AuthScreen(),
            AddEditTaskCategoryScreen.routeName: (context) =>
                const AddEditTaskCategoryScreen(),
            SettingsScreen.routeName: (context) => SettingsScreen(
                  saveFilters: _setFilters,
                  currentFilters: _filters,
                ),
          },
        ));
  }

  void _setFilters(Map<String, dynamic> filterData, BuildContext context_) {
    //save filters in shared preferences
    saveFiltersInSP(filterData).then((value) => {
          setState(() {
            _filters = filterData;
          }),
          //check if location based notification is enabled
          if (_filters['locationBasedNotification'] != false &&
              _filters['intervalOfNotification'] != null)
            {
              LocationBasedNotificationService.turnOff(),
              LocationBasedNotificationService.turnOn(
                  context_, _filters['intervalOfNotification']),
            }
          else
            {
              LocationBasedNotificationService.turnOff(),
            }
        });
  }
}
