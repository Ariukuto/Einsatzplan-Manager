import 'package:einsatzplaene/OperationPlansPage/OperationPlansPage.ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

	final lightTheme = ThemeData(
  	primaryColor: Colors.blue,
		errorColor: Colors.red,
		iconTheme: const IconThemeData(
			color: Colors.white,
		),
    useMaterial3: true,
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      home: const OperationPlansPage(title: 'FFW Marktbreit'),
    );
  }
}




