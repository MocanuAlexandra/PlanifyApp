import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/category.dart';

class Categories with ChangeNotifier {
  List<Category> _categories = [];

  List<Category> get categoriesList {
    return [..._categories];
  }

  Future<void> fetchCategories() async {
    final categoriesData = await DBHelper.fetchCategories();

    _categories = categoriesData.map(
      (category) {
        return Category(
          id: category['id'],
          name: category['name'],
        );
      },
    ).toList();
  }
}
