import 'package:detrack_test/viewmodels/tracker_viewmodel.dart';
import 'package:detrack_test/views/tracker_page.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final trackerViewModel = TrackerViewModel();

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
