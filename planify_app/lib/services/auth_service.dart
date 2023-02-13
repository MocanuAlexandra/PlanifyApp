import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static Future<OAuthCredential> getUserCredentials() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    final credentials = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    return credentials;
  }

  static Future<void> addUserDataInDB(UserCredential userCredentials) async {
    //add the username as extra field
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredentials.user!.uid)
        .set({'email': userCredentials.user!.email});

    //get the user's categories
    final categories = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredentials.user!.uid)
        .collection('categories')
        .get();

    //check if the user has categories
    if (categories.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .collection('categories')
          .add({'name': 'No category'});
    } else {
      //add default category if it doesn't exist
      for (var element in categories.docs) {
        if (element.data()['name'] != 'No category') {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredentials.user!.uid)
              .collection('categories')
              .add({'name': 'No category'});
        }
      }
    }
  }
}
