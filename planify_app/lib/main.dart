import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planify_app/providers/task_reminder_provider.dart';
import 'package:planify_app/services/location_based_notification_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'providers/category_provider.dart';
import 'screens/agenda/task_category_agenda_screen.dart';
import 'screens/agenda/deleted_agenda_screen.dart';
import 'screens/task/add_edit_task_category_screen.dart';
import 'providers/task_provider.dart';
import 'services/notification_service.dart';
import 'screens/task/task_details_screen.dart';
import '../../screens/agenda/month_agenda_screen.dart';
import '../../screens/agenda/today_agenda_screen.dart';
import '../../screens/auth/auth_screen.dart';
import '../../screens/agenda/overall_agenda_screen.dart';
import 'screens/task/add_edit_task_screen.dart';

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
  @override
  void initState() {
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
            create: (context) => CategoryProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => TaskReminderProvider(),
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
                final notificationService = LocationBasedNotificationService();
                notificationService.initialize(context);
                return const OverallAgendaScreen();
              }
              return const AuthScreen();
            },
          ),
          routes: {
            OverallAgendaScreen.routeName: (context) =>
                const OverallAgendaScreen(),
            TodayAgendaScreen.routeName: (context) => const TodayAgendaScreen(),
            MonthAgendaScreen.routeName: (context) => const MonthAgendaScreen(),
            AddEditTaskScreen.routeName: (context) => const AddEditTaskScreen(),
            TaskDetailsScreen.routeName: (context) => const TaskDetailsScreen(),
            AuthScreen.routeName: (context) => const AuthScreen(),
            DeletedAgendaScreen.routeName: (context) =>
                const DeletedAgendaScreen(),
            TaskCategoryAgendaScreen.routeName: (context) =>
                const TaskCategoryAgendaScreen(),
            AddEditTaskCategoryScreen.routeName: (context) =>
                const AddEditTaskCategoryScreen(),
          },
        ));
  }
}
