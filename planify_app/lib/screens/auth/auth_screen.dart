import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 78, 195, 199),
                  Color.fromARGB(255, 1, 55, 58),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //logo image
                  Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: const SizedBox(
                      width: 200,
                      height: 200,
                      child: Image(
                        image: AssetImage('assets/images/icon.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // the form
                  Flexible(
                    child: AuthForm(
                      googleSignIn: submitGoogleSignIn,
                      submitFn: submitAuthForm,
                      isLoading: _isLoading,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void displayFirebaseAuthErrors(
      FirebaseAuthException error, BuildContext ctx) {
    var message = 'An error occurred, please check your credentials';
    if (error.message != null) {
      message = error.message!;
    }

    //show a snack bar with the error to the user
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
    setState(() {
      _isLoading = false;
    });
  }

  void displayOtherAuthErrors(BuildContext ctx, Object error) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(error.toString()),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> submitAuthForm(
      String email, String password, bool isLogin, BuildContext ctx) async {
    UserCredential userCredential;

    //try to login or sign up
    try {
      setState(() {
        _isLoading = true;
      });

      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        //add the username as extra field in DB, and add default category if it doesn't exist
        await AuthService.addUserDataInDB(userCredential);
      }
      //handle errors
    } on FirebaseAuthException catch (error) {
      displayFirebaseAuthErrors(error, ctx);
    } catch (error) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(error.toString()),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> submitGoogleSignIn(BuildContext ctx) async {
    try {
      setState(() {
        _isLoading = true;
      });

      //get the user's credentials then sign in with them
      OAuthCredential credentials = await AuthService.getUserCredentials();
      UserCredential userCredentials =
          await FirebaseAuth.instance.signInWithCredential(credentials);

      //add the username as extra field in DB, and add default category if it doesn't exist
      await AuthService.addUserDataInDB(userCredentials);
    } on FirebaseAuthException catch (error) {
      displayFirebaseAuthErrors(error, ctx);
    } catch (error) {
      displayOtherAuthErrors(ctx, error);
    }
  }
}
