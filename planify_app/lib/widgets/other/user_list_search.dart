import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/user_provider.dart';

class UserListSearch extends StatefulWidget {
  const UserListSearch({super.key});

  @override
  State<UserListSearch> createState() => _UserListSearchState();
}

class _UserListSearchState extends State<UserListSearch> {
  List<AppUser> _users = [];

  List<String> filterItems = [];
  List<String> checkedItems = [];

  late final TextEditingController controller = TextEditingController()
    ..addListener(() {
      /// filter logic will be here
      final text = controller.text.trim();
      filterItems = _users
          .where((element) => element.email!.contains(text))
          .map((e) => e.email!)
          .toList();

      setState(() {});
    });

  @override
  void initState() {
    _fetchUsers(context);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: AlertDialog(
        title: const Text(
          "Search users",
        ),
        content: SizedBox(
          height: 250,
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Type',
                  suffixIcon: Icon(
                    Icons.search,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: filterItems.length,
                    itemBuilder: (context, index) {
                      final bool isChecked =
                          checkedItems.contains(filterItems[index]);
                      return CheckboxListTile(
                        value: isChecked,
                        title: Text(filterItems[index]),
                        onChanged: (value) {
                          if (isChecked) {
                            checkedItems.remove(filterItems[index]);
                          } else {
                            checkedItems.add(filterItems[index]);
                          }
                          setState(() {});
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Ok"),
          ),
        ],
      ),
    );
  }

  void _fetchUsers(BuildContext context) async {
    _users =
        await Provider.of<UserProvider>(context, listen: false).fetchUsers();
  }
}
