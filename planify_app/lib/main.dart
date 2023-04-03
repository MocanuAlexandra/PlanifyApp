import 'dart:convert';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/task_provider.dart';
import '../../providers/task_reminder_provider.dart';
import '../../screens/auth/auth_screen.dart';
import '../../screens/settings_screen.dart';
import 'screens/task_related/add_edit_task_category_screen.dart';
import 'screens/task_related/add_edit_task_screen.dart';
import 'screens/task_related/task_details_screen.dart';
import '../../services/location_based_notification_service.dart';
import '../../services/notification_service.dart';
import 'providers/task_category_provider.dart';
import 'providers/user_provider.dart';
import 'screens/pages/category_agenda_page.dart';
import 'screens/pages/deleted_agenda_page.dart';
import 'screens/pages/month_agenda_page.dart';
import 'screens/pages/overall_agenda_page.dart';
import 'screens/pages/today_agenda_page.dart';
import 'screens/tabs_in_pages/my_agenda/month_agenda_tab.dart';
import 'screens/tabs_in_pages/my_agenda/overall_agenda_tab.dart';
import 'screens/tabs_in_pages/my_agenda/today_agenda_tab.dart';
import 'screens/tabs_in_pages/shared_agenda/shared_month_agenda_tab.dart';
import 'screens/tabs_in_pages/shared_agenda/shared_overrall_agenda_tab.dart';
import 'screens/tabs_in_pages/shared_agenda/shared_today_agenda_tab.dart';

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
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: const Color.fromARGB(255, 66, 173, 176),
              secondary: const Color.fromARGB(255, 1, 96, 100),
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
            SharedOverallAgendaTab.routeName: (context) =>
                const SharedOverallAgendaTab(),
            TodayAgendaPage.routeName: (context) => const TodayAgendaPage(),
            TodayAgendaTab.routeName: (context) => const TodayAgendaTab(),
            SharedTodayAgendaTab.routeName: (context) =>
                const SharedTodayAgendaTab(),
            MonthAgendaPage.routeName: (context) => const MonthAgendaPage(),
            MonthAgendaTab.routeName: (context) => const MonthAgendaTab(),
            SharedMonthAgendaTab.routeName: (context) =>
                const SharedMonthAgendaTab(),
            DeletedAgendaPage.routeName: (context) => const DeletedAgendaPage(),
            CategoryAgendaPage.routeName: (context) =>
                const CategoryAgendaPage(),
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
    saveFiltersInSP(filterData).then((value) async => {
          setState(() {
            _filters = filterData;
          }),
          //check if location based notification is enabled
          if (_filters['locationBasedNotification'] != false &&
              _filters['intervalOfNotification'] != null)
            {
              await LocationBasedNotificationService.turnOff(),
              await LocationBasedNotificationService.turnOn(
                  context_, _filters['intervalOfNotification']),
            }
          else
            {
              await LocationBasedNotificationService.turnOff(),
            }
        });
  }
}
