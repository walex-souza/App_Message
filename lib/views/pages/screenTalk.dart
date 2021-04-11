import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/models/User.model.dart';
import 'package:whatsapp/models/talk.model.dart';

class ScreenTalk extends StatefulWidget {
  @override
  _ScreenTalkState createState() => _ScreenTalkState();
}

class _ScreenTalkState extends State<ScreenTalk> {
  List<Talk> _listTalk = List();
  String _idLoggedUser;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;

  Stream<QuerySnapshot> _addListenerTalk() {
    final stream = db
        .collection("Conversas")
        .document(_idLoggedUser)
        .collection("ultima_conversa")
        .snapshots();

    stream.listen(
      (data) {
        _controller.add(data);
      },
    );
  }

  _getDataUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idLoggedUser = loggedUser.uid;

    _addListenerTalk();
  }

  @override
  void initState() {
    super.initState();
    _getDataUser();

    Talk talk = Talk();

    talk.name = "Jamiltom";
    talk.message = "Olá tudo bem ?";
    talk.image =
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-30578.appspot.com/o/Perfil%2Fperfil5.jpg?alt=media&token=9bca2f10-9586-491f-ad9d-ecaf6e72d29f";

    _listTalk.add(talk);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [
                  Text("Carregando conversas..."),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              Text("Erro ao carregar dados!");
            } else {
              QuerySnapshot querySnapshot = snapshot.data;
              if (querySnapshot.documents.length == 0) {
                return Center(
                  child: Text(
                    "Você não tem nenhuma mensagem ainda :(",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: querySnapshot.documents.length,
                itemBuilder: (context, index) {
                  List<DocumentSnapshot> talks =
                      querySnapshot.documents.toList();
                  DocumentSnapshot item = talks[index];

                  String urlImage = item["image"];
                  String type = item["typeMessage"];
                  String message = item["message"];
                  String name = item["name"];
                  String idDestinatario = item["idDestinatario"];

                  User user = User();
                  user.name = name;
                  user.urlImage = urlImage;
                  user.idUser = idDestinatario;

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
                      backgroundImage:
                          urlImage != null ? NetworkImage(urlImage) : null,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      type == "text" ? message : "Imagem...",
                    ),
                  );
                },
              );
            }
        }
      },
    );
  }
}
