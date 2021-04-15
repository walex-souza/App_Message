import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/views/pages/screenContact.dart';
import 'package:whatsapp/views/pages/screenTalk.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;

  _selectedMenuItem(String selectedItem) {
    switch (selectedItem) {
      case "Configuraçôes":
        Navigator.pushNamed(context, "/settings");
        break;
      case "Deslogar":
        _signOutUser();
        Navigator.pushReplacementNamed(context, "/login");
        break;
      default:
    }
  }

  _signOutUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
  }

  List<String> itensMenu = [
    "Configuraçôes",
    "Deslogar",
  ];

  Future _checkUserLogin() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut();

    FirebaseUser firebaseUser = await auth.currentUser();

    if (firebaseUser == null) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserLogin();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff050A6A),
        title: Text(""),
        bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            controller: _tabController,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                text: "Mensagens",
              ),
              Tab(
                text: "Contatos",
              )
            ]),
        actions: [
          PopupMenuButton<String>(
            onSelected: _selectedMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Color(0xff050A6A),
              Color(0xff03063D),
            ])),
        child: TabBarView(controller: _tabController, children: [
          ScreenTalk(),
          ScreenContact(),
        ]),
      ),
    );
  }
}
