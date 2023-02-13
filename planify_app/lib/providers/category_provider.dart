import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/location_category.dart';

class CategoryProvider with ChangeNotifier {
  List<LocationCategory> _categories = [];

  List<LocationCategory> get categoriesList {
    return [..._categories];
  }

  Future<void> fetchCategories() async {
    final categoriesData = await DBHelper.fetchCategories();

    _categories = categoriesData.map(
      (category) {
        return LocationCategory(
          id: category['id'],
          name: category['name'],
        );
      },
    ).toList();
  }

  LocationCategory findByName(String categoryName) {
    return _categories.firstWhere((category) => category.name == categoryName);
  }
}
