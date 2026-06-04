import 'package:detrack_test/services/history_services.dart';
import 'package:detrack_test/viewmodels/tracker_viewmodel.dart';
import 'package:detrack_test/views/tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final historyService = HistoryService(prefs);
  final trackerViewModel = TrackerViewModel(historyService: historyService);

  runApp(MyApp(viewModel: trackerViewModel));
}

class MyApp extends StatelessWidget {
  final TrackerViewModel viewModel;
  const MyApp({super.key, required this.viewModel});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: TrackerPage(viewModel: viewModel),
    );
  }
}
