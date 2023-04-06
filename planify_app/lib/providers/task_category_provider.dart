import 'package:flutter/material.dart';

import '../services/database_helper_service.dart';
import '../models/task_category.dart';

class TaskCategoryProvider with ChangeNotifier {
  List<TaskCategory> _categories = [];

  List<TaskCategory> get categoriesList {
    return [..._categories];
  }

  Future<void> fetchCategories() async {
    final categoriesData = await DBHelper.fetchTaskCategories();

    _categories = categoriesData.map(
      (category) {
        return TaskCategory(
          id: category['id'],
          name: category['name'],
          iconCode: category['iconCode'],
        );
      },
    ).toList();
  }

  TaskCategory findByName(String categoryName) {
    return _categories.firstWhere((category) => category.name == categoryName);
  }

  int getCategoryIcon(String categoryName) {
    TaskCategory category = findByName(categoryName);
    return category.iconCode!;
  }
}
