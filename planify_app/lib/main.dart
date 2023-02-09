import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planify_app/providers/reminders.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'providers/categories.dart';
import 'screens/agenda/category_agenda_screen.dart';
import 'screens/agenda/deleted_agenda_screen.dart';
import 'screens/task/add_edit_category_screen.dart';
import '../../providers/tasks.dart';
import 'helpers/notification_helper.dart';
import 'screens/task/task_detail_screen.dart';
import '../../screens/agenda/month_agenda_screen.dart';
import '../../screens/agenda/today_agenda_screen.dart';
import '../../screens/auth/auth_screen.dart';
import '../../screens/agenda/overall_agenda_screen.dart';
import 'screens/task/add_edit_task_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationHelper.initialize();
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
    NotificationHelper.setListeners(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Tasks(),
          ),
          ChangeNotifierProvider(
            create: (context) => Categories(),
          ),
          ChangeNotifierProvider(
            create: (context) => TaskReminders(),
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
            TaskDetailScreen.routeName: (context) => const TaskDetailScreen(),
            AuthScreen.routeName: (context) => const AuthScreen(),
            DeletedAgendaScreen.routeName: (context) =>
                const DeletedAgendaScreen(),
            CategoryAgendaScreen.routeName: (context) =>
                const CategoryAgendaScreen(),
            AddEditCategoryScreen.routeName: (context) =>
                const AddEditCategoryScreen(),
          },
        ));
  }
}
