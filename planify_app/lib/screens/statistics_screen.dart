import 'package:flutter/material.dart';

import '../widgets/drawer.dart';

class StatisticsScreen extends StatefulWidget {
  static const routeName = '/statistics';

  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
        ),
        drawer: const MainDrawer(),
        body: const Center(
          child: Text('Statistics here'),
        ));
  }
}
