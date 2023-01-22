import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planify_app/screens/task_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';

import './providers/tasks.dart';
import './screens/agenda/month_agenda_screen.dart';
import './screens/agenda/today_agenda_screen.dart';
import './screens/auth/auth_screen.dart';
import './screens/agenda/overall_agenda_screen.dart';
import './widgets/task/add_new_task_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: Tasks(),
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
            AddNewTaskForm.routeName: (context) => const AddNewTaskForm(),
            TaskDetailScreen.routeName: (context) => const TaskDetailScreen(),
          },
        ));
  }
}
