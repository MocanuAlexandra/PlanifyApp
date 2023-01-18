import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:planify_app/providers/tasks.dart';
import 'package:planify_app/widgets/task/add_new_task_form.dart';
import 'package:provider/provider.dart';

import 'screens/auth/auth_screen.dart';
import 'screens/agenda/overall_agenda_screen.dart';
import 'firebase_options.dart';

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
              primary: const Color.fromARGB(255, 19, 208, 164),
              secondary: const Color.fromARGB(255, 228, 120, 207),
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
            AddNewTaskForm.routeName: (context) => const AddNewTaskForm(),
          },
        ));
  }
}
