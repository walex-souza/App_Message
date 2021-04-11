import 'package:flutter/material.dart';
import 'package:whatsapp/views/RouteGenerator.dart';
import 'package:whatsapp/views/login.dart';

void main() {
  runApp(MaterialApp(
    home: Login(),
    theme:
        ThemeData(primaryColor: Colors.green, accentColor: Colors.green[900]),
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
  ));
}
