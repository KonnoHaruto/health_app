import 'package:flutter/material.dart';
import 'package:health/health.dart';

void main() => runApp(const HealthApp());

class HealthApp extends StatefulWidget {
  const HealthApp({Key? key}) : super(key: key);

  @override
  _HealthAppState createState() => _HealthAppState();
}

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED,
  DATA_ADDED,
  DATA_NOT_ADDED,
  STEPS_READY,
}

class _HealthAppState extends State<HealthApp> {
  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  int _nofSteps = 10;
  double _mgdl = 10.0;

  HealthFactory health = HealthFactory();

  Future fetchData() async {
    setState(() => _state = AppState.FETCHING_DATA);

    final types = [HealthDataType.STEPS];
    final permissions = [HealthDataAccess.READ];

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    bool requested =
        await health.requestAuthorization(types, permissions: permissions);

    if (requested) {
      try {
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(yesterday, now, types);

        _healthDataList.addAll(
          (healthData.length < 100) ? healthData : healthData.sublist(0, 100),
        );
      } catch (error) {
        // ignore: avoid_print
        print("Exception in getHealthDataFromTypes: $error");
      }

      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
      
      // ignore: avoid_print
      _healthDataList.forEach((data) => print(data));

      setState(() {
        _state =
            _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
      });
    } else {
      //ignore: avoid_print
      print("Authorization not granted");
      setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Health Example'),
        ),
      ),
    );
  }
}
