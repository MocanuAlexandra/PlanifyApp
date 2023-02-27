import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  List<AppUser> _users = [];

  List<AppUser> get usersList {
    return [..._users];
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

    return _users;
  }
}
