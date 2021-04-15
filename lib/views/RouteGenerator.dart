import 'package:flutter/material.dart';
import 'package:whatsapp/views/home.dart';
import 'package:whatsapp/views/login.dart';
import 'package:whatsapp/views/pages/screenMessage.dart';
import 'package:whatsapp/views/pages/screenSettings.dart';
import 'package:whatsapp/views/register.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    List<dynamic> args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Login());
        break;
      case "/login":
        return MaterialPageRoute(builder: (_) => Login());
        break;
      case "/register":
        return MaterialPageRoute(builder: (_) => Register());
        break;
      case "/home":
        return MaterialPageRoute(builder: (context) => Home());
        break;
      case "/settings":
        return MaterialPageRoute(builder: (context) => ScreenSettings());
        break;
      case "/message":
        return MaterialPageRoute(
            builder: (context) => ScreenMessage(args[0], args[1]));
        break;

      default:
    }
  }
}
