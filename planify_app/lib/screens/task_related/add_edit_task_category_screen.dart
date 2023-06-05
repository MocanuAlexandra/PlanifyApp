import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/database_helper_service.dart';
import '../../helpers/utility.dart';
import '../../models/task_category.dart';
import '../../providers/task_category_provider.dart';
import '../pages/overall_agenda_page.dart';

class AddEditTaskCategoryScreen extends StatefulWidget {
  static const routeName = '/add-category';

  const AddEditTaskCategoryScreen({super.key});

  @override
  State<AddEditTaskCategoryScreen> createState() =>
      _AddEditTaskCategoryScreenState();
}

class _AddEditTaskCategoryScreenState extends State<AddEditTaskCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  var _editedCategory = TaskCategory(
    id: null,
    name: '',
    iconCode: 57672, // Icons.category is default
  );

  var _initValues = {
    'name': '',
  };

  var _isInit = true;

  Widget _buildIconGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      itemCount: Utility.iconList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (ctx, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _editedCategory.iconCode = Utility.iconList[index].codePoint;
            });
          },
          child: CircleAvatar(
            backgroundColor:
                _editedCategory.iconCode == Utility.iconList[index].codePoint
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            child: _editedCategory.iconCode == Utility.iconList[index].codePoint
                ? Icon(Utility.iconList[index],
                    color: Theme.of(context).colorScheme.onPrimary)
                : Icon(Utility.iconList[index], color: Colors.black),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final buttonHeight = screenHeight * 0.08;

    return Scaffold(
      appBar: AppBar(
        title: _editedCategory.id == null
            ? const Text('Add new category')
            : const Text('Edit category'),
        actions: [
          if (_editedCategory.id != null)
            IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  //check if the category is the default category
                  if (_editedCategory.name == 'Uncategorized') {
                    Utility.displayInformationalDialog(
                        context, 'You cannot delete the default category.');
                    return;
                  } else {
                    //check if the category is used in any task
                    DBHelper.isTaskCategoryUsed(_editedCategory.id!)
                        .then((value) {
                      if (value) {
                        Utility.displayInformationalDialog(context,
                            'You cannot delete this category because it is used in one or more tasks.');
                        return;
                      } else {
                        //delete category
                        Utility.displayQuestionDialog(context,
                                'Do you want to permanently delete this category?')
                            .then((value) {
                          if (value!) {
                            DBHelper.deleteTaskCategory(_editedCategory.id!);
                            Navigator.of(context).pushReplacementNamed(
                                OverallAgendaPage.routeName);
                          }
                        });
                      }
                    });
                  }
                }),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Form(
            key: _formKey,
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _initValues['name'],
                      decoration:
                          const InputDecoration(labelText: 'Category name'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        _addEditCategory();
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Required field';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedCategory.name = value;
                      },
                    ),
                    Expanded(child: _buildIconGrid()),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: buttonHeight,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 15),
              child: ElevatedButton(
                  onPressed: _addEditCategory,
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 18),
                  )),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final categoryName =
          ModalRoute.of(context)!.settings.arguments as String?;

      if (categoryName != null) {
        _editedCategory =
            Provider.of<TaskCategoryProvider>(context, listen: false)
                .findByName(categoryName);
        _initValues = {
          'name': _editedCategory.name!,
        };
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _addEditCategory() {
    //check if form is valid
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();

      //check if we got an id
      if (_editedCategory.id != null) {
        //check if category already exists
        if (Provider.of<TaskCategoryProvider>(context, listen: false)
                .findByName(_editedCategory.name!)
                .name !=
            '') {
          Utility.displayInformationalDialog(
              context, 'This category already exists.');
          return;
        }

        //update category
        DBHelper.updateTaskCategory(_editedCategory.id!, _editedCategory);

        // go back to overall agenda screen
        Navigator.of(context).pushReplacementNamed(OverallAgendaPage.routeName);
      } else {
        //check if category already exists
        if (Provider.of<TaskCategoryProvider>(context, listen: false)
                .findByName(_editedCategory.name!)
                .name !=
            '') {
          Utility.displayInformationalDialog(
              context, 'This category already exists.');
          return;
        }

        //add category
        DBHelper.addTaskCategory(_editedCategory);

        // go back to overall agenda screen
        Navigator.of(context).pushReplacementNamed(OverallAgendaPage.routeName);
      }
    }
  }
}
