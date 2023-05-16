import 'package:flutter/material.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:planify_app/services/database_helper_service.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../providers/task_provider.dart';
import '../widgets/drawer.dart';

class StatisticsScreen extends StatefulWidget {
  static const routeName = '/statistics';

  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final ScrollController _controller = ScrollController();
  FilterOptions selectedOption = FilterOptions.inProgress;
  DateTime _selectedDate = DateTime.now();

  void _presentMonthPicker() async {
    final DateTime? picked = await showMonthPicker(
      headerColor: Theme.of(context).colorScheme.primary,
      confirmText: Text(
        'OK',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      cancelText: Text(
        'CANCEL',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _presentMonthPicker,
          ),
        ],
      ),
      drawer: const MainDrawer(),
      body: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        thickness: 5,
        child: SingleChildScrollView(
          controller: _controller,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //******** Progress bar with completed tasks for the selected month *********
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Completed Tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<double?>(
                  future: _calculateProgressPercentage(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final progressPercentage = snapshot.data!;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SfLinearGauge(
                            minimum: 0,
                            maximum: 1,
                            showTicks: false,
                            showLabels: false,
                            animateAxis: true,
                            axisTrackStyle: LinearAxisTrackStyle(
                              thickness: 30,
                              edgeStyle: LinearEdgeStyle.bothCurve,
                              borderWidth: 1,
                              borderColor: Colors.grey[350],
                              color: Colors.grey[350],
                            ),
                            barPointers: [
                              LinearBarPointer(
                                value: progressPercentage,
                                color: Colors.green,
                                thickness: 30,
                                edgeStyle: LinearEdgeStyle.bothCurve,
                              ),
                            ],
                          ),
                          Text(
                            '${(progressPercentage * 100).toStringAsFixed(2)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                const Divider(),
                ///////////////////////////////////////////////////////////////////////
                //*************************** Categories pie ************************************ */
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Categories overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<double?> _calculateProgressPercentage() async {
    final completedTasks = await DBHelper.getDoneTasksForMonth(_selectedDate);
    final totalTasks = await DBHelper.getListOfTasks();
    if (totalTasks.isEmpty) {
      return null;
    }
    return completedTasks.length / totalTasks.length;
  }
}
