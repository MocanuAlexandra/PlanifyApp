import 'package:flutter/material.dart';
import 'package:month_picker_dialog_2/month_picker_dialog_2.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:planify_app/services/database_helper_service.dart';

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
      initialDate: _selectedDate,
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
                  child: Center(
                    child: Text(
                      'Completed Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                FutureBuilder<double?>(
                  future: _calculateProgressPercentage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final progressPercentage = snapshot.data ?? 0;
                      return SizedBox(
                        height: 100,
                        child: Stack(
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
                        ),
                      );
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
                  child: Center(
                    child: Text(
                      'Categories overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                FutureBuilder<List<CategoryData>>(
                  future: _getCategoriesData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final categoryDataList = snapshot.data ?? [];

                      return categoryDataList.isEmpty
                          ? const SizedBox(
                              height: 100,
                              child: Center(
                                child: Text(
                                  'No data available for this month',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 300,
                              child: _buildCategoryPieChart(categoryDataList),
                            );
                    }
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                const Divider(),
                ///////////////////////////////////////////////////////////////////////
              ],
            ),
          ),
        ),
      ),
    );
  }

  SfCircularChart _buildCategoryPieChart(List<CategoryData> categoryDataList) {
    return SfCircularChart(
      title: ChartTitle(
        text: '',
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      legend: Legend(isVisible: true),
      series: _getCategoryPieSeries(categoryDataList),
    );
  }

  List<PieSeries<CategoryData, String>> _getCategoryPieSeries(
      List<CategoryData> categoryDataList) {
    return <PieSeries<CategoryData, String>>[
      PieSeries<CategoryData, String>(
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        dataSource: categoryDataList,
        xValueMapper: (CategoryData data, _) => data.category,
        yValueMapper: (CategoryData data, _) => data.percentage,
        dataLabelMapper: (CategoryData data, _) =>
            '${(data.percentage * 100).toStringAsFixed(2)}%',
        startAngle: 90,
        endAngle: 90,
        dataLabelSettings: const DataLabelSettings(isVisible: true),
      ),
    ];
  }

  Future<double?> _calculateProgressPercentage() async {
    final completedTasks = await DBHelper.getDoneTasksForMonth(_selectedDate);
    final totalTasks = await DBHelper.getTasksForMonth(_selectedDate);
    if (totalTasks.isEmpty) {
      return null;
    }
    return completedTasks.length / totalTasks.length;
  }

  Future<List<CategoryData>> _getCategoriesData() async {
    final totalTasks = await DBHelper.getTasksForMonth(_selectedDate);

    final categoryCountMap = <String, int>{};
    for (final task in totalTasks) {
      categoryCountMap[task.category!] =
          (categoryCountMap[task.category] ?? 0) + 1;
    }

    final categoryDataList = <CategoryData>[];
    for (final category in categoryCountMap.keys) {
      final count = categoryCountMap[category]!;
      final percentage = count > 0 ? count / totalTasks.length : 0;
      categoryDataList.add(CategoryData(category, percentage.toDouble()));
    }
    return categoryDataList;
  }
}

class CategoryData {
  final String category;
  final double percentage;

  CategoryData(this.category, this.percentage);
}
