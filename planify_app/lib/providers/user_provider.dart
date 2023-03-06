import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  List<AppUser> _users = [];
  String _email = '';

  List<AppUser> get usersList {
    return [..._users];
  }

  String get email {
    return _email;
  }

  Future<List<AppUser>> fetchUsers() async {
    final usersData = await DBHelper.fetchUsers();

    _users = usersData.map(
      (user) {
        return AppUser(
          id: user['id'],
          email: user['email'],
        );
      },
    ).toList();

    // eliminate the current user from the list
    _users.removeWhere((user) => user.id == DBHelper.currentUserId());

    return _users;
  }

  Future<void> getEmailByUserId(String userId) async {
    var userEmail = await DBHelper.returnEmailByUserId(userId);
    _email = userEmail;
  }
}
