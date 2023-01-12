import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

import '../screens/auth_screen.dart';
import '../screens/overall_agenda.dart';
import '../helpers/custom_page_transitions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Planify App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 199, 82, 246),
          secondary:const Color.fromARGB(255, 251, 157, 56),
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
            TargetPlatform.iOS: CustomPageTransitionBuilder()
          },
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
        OverallAgendaScreen.routeName: (context) => const OverallAgendaScreen(),
      },
    );
  }
}
