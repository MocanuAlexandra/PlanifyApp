import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/database_helper.dart';
import '../../helpers/utility.dart';
import '../../models/task_category.dart';
import '../../providers/task_category_provider.dart';
import '../pages/overall_agenda_page.dart';
import '../tabs/my_agenda/overall_agenda_tab.dart';

class AddEditTaskCategoryScreen extends StatefulWidget {
  const AddEditTaskCategoryScreen({super.key});

  static const routeName = '/add-category';

  @override
  State<AddEditTaskCategoryScreen> createState() =>
      _AddEditTaskCategoryScreenState();
}

class _AddEditTaskCategoryScreenState extends State<AddEditTaskCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  var _editedCategory = TaskCategory(
    id: null,
    name: '',
  );

  var _initValues = {
    'name': '',
  };

  var _isInit = true;

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
        //update category
        DBHelper.updateTaskCategory(_editedCategory.id!, _editedCategory);

        // go back to overall agenda screen
        Navigator.of(context).pushReplacementNamed(OverallAgendaPage.routeName);
      } else {
        //add category
        DBHelper.addTaskCategory(_editedCategory);

        // go back to overall agenda screen
        Navigator.of(context).pushReplacementNamed(OverallAgendaPage.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  if (_editedCategory.name == 'No category') {
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
                            _deleteCategory(context, _editedCategory.id!);
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.end,
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
                          _editedCategory = TaskCategory(
                            id: _editedCategory.id,
                            name: value,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 70),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _addEditCategory,
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 18),
                      )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(BuildContext context, String categoryId) {
    DBHelper.deleteCategory(categoryId);
    Navigator.of(context).pushReplacementNamed(OverallAgendaPage.routeName);
  }
}
