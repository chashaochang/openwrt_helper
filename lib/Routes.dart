import 'package:flutter/material.dart';

import '/pages/home/HomePage.dart';
import '/pages/login/LoginPage.dart';

class RouteConfiguration{

  static final routes = {
    '/': (context) => const HomePage(title: 'Flutter Demo Home Page'),
    '/login': (context) => const LoginPage(title: 'page B'),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final String? name = settings.name;
    final Function? pageContentBuilder = routes[name];
    if (pageContentBuilder != null) {
      if (settings.arguments != null) {
        return MaterialPageRoute(builder: (context) =>
            pageContentBuilder(context, arguments: settings.arguments));
      }else{
        return MaterialPageRoute(builder: (context) =>
            pageContentBuilder(context));
      }
    }
    return null;
  }

}
