import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/models/User.model.dart';

class ScreenContact extends StatefulWidget {
  @override
  _ScreenContactState createState() => _ScreenContactState();
}

class _ScreenContactState extends State<ScreenContact> {
  String _idLoggedUser;
  String _emailLoggedUser;

  Future<List<User>> _getContact() async {
    Firestore db = Firestore.instance;

    QuerySnapshot querySnapshot =
        await db.collection("Usuarios").getDocuments();

    List<User> listUsers = List();

    for (DocumentSnapshot item in querySnapshot.documents) {
      var data = item.data;

      if (data["email"] == _emailLoggedUser) continue;

      User user = User();
      user.idUser = item.documentID;
      user.email = data["email"];
      user.name = data["name"];
      user.urlImage = data["urlImage"];

      listUsers.add(user);
    }
    return listUsers;
  }

  _getDataUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idLoggedUser = loggedUser.uid;
    _emailLoggedUser = loggedUser.email;
  }

  @override
  void initState() {
    super.initState();
    _getDataUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getContact(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [
                  Text("Carregando contatos..."),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return Container(
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  List<User> list = snapshot.data;
                  User user = list[index];

                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/message",
                        arguments: [user, _idLoggedUser],
                      );
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: user.urlImage != null
                            ? NetworkImage(user.urlImage)
                            : null),
                    title: Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            );
            break;
          default:
        }
      },
    );
  }
}
