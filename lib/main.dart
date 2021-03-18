import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/views/login.dart';

void main() {
  
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance
  .collection("Usuarios")
  .document("002")
  .setData({"mesagem" : "oi"});

  runApp(MaterialApp(
    home: Login(),
    theme: ThemeData(
      primaryColor: Colors.green,
      accentColor: Colors.green[900]
    ),
  ));
}

