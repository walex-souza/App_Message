import 'package:flutter/material.dart';
import 'package:whatsapp/views/RouteGenerator.dart';
import 'package:whatsapp/views/login.dart';

void main() {
  runApp(MaterialApp(
    home: Login(),
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
  ));
}
