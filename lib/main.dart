import 'package:flutter/material.dart';
import 'package:openwrt_helper/Routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      initialRoute: "/",
      onGenerateRoute: RouteConfiguration.onGenerateRoute,
    );
  }
}