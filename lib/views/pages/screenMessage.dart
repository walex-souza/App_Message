import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/models/Message.model.dart';
import 'package:whatsapp/models/User.model.dart';
import 'package:whatsapp/models/talk.model.dart';

class ScreenMessage extends StatefulWidget {
  User contact;
  String idUser;
  ScreenMessage(
    this.contact,
    this.idUser,
  );
  @override
  _ScreenMessageState createState() => _ScreenMessageState();
}

class _ScreenMessageState extends State<ScreenMessage> {
  TextEditingController _controllerMessage = TextEditingController();
  String _idLoggedUser;
  String _idUserReceiver;
  File _image;
  bool _upImage = false;
  Firestore db = Firestore.instance;

  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

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

  _sendMessage() async {
    String messageUser = _controllerMessage.text;

    if (messageUser.isNotEmpty) {
      Message message = Message();
      message.idUser = _idLoggedUser;
      message.message = messageUser;
      message.urlImage = "";
      message.date = Timestamp.now().toString();
      message.type = "text";

      //Salvar mensagem para o rementente
      _saveMessage(_idLoggedUser, _idUserReceiver, message);

      //Salvar mensagem para o destinatario
      _saveMessage(_idUserReceiver, _idLoggedUser, message);
      // Salvar conversa
      _salveTalk(message);
    }
  }

  _saveMessage(String idRementente, String idDestinatario, Message msg) async {
    await db
        .collection("Mensagem")
        .document(idRementente)
        .collection(idDestinatario)
        .add(msg.toMap());

    _controllerMessage.clear();
  }

  _salveTalk(Message msg) {
    //Salvar conversa remetente
    Talk cRemetente = Talk();
    cRemetente.idRementente = _idLoggedUser;
    cRemetente.idDestinatario = _idUserReceiver;
    cRemetente.message = msg.message;
    cRemetente.name = widget.contact.name;
    cRemetente.image = widget.contact.urlImage;
    cRemetente.typeMessage = msg.type;
    cRemetente.save();

    //Salvar conversa destinatario
    Talk cDestinatario = Talk();
    cDestinatario.idRementente = _idUserReceiver;
    cDestinatario.idDestinatario = _idLoggedUser;
    cDestinatario.message = msg.message;
    cDestinatario.name = widget.contact.name;
    cDestinatario.image = widget.contact.urlImage;
    cDestinatario.typeMessage = msg.type;
    cDestinatario.save();
  }

  _sendImage() async {
    final picker = ImagePicker();
    File imagemSelected;
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    imagemSelected = File(pickedFile.path);

    _upImage = true;
    String nameImage = DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference folder = storage.ref();
    StorageReference file =
        folder.child("mensagem").child(_idLoggedUser).child(nameImage + ".jpg");

    //Upload da imagem
    StorageUploadTask task = file.putFile(imagemSelected);

    //Controlador de progresso do upload
    task.events.listen((StorageTaskEvent storageTaskEvent) {
      if (storageTaskEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _upImage = true;
        });
      } else if (storageTaskEvent.type == StorageTaskEventType.success) {
        setState(() {
          _upImage = false;
        });
      }
    });
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _getUrlImage(snapshot);
    });
  }

  Future _getUrlImage(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Message message = Message();
    message.idUser = _idLoggedUser;
    message.message = "";
    message.urlImage = url;
    message.date = Timestamp.now().toString();
    message.type = "image";

    //Salvar imagem para o rementente
    _saveMessage(_idLoggedUser, _idUserReceiver, message);

    //Salvar imagem para o destinatario
    _saveMessage(_idUserReceiver, _idLoggedUser, message);
  }

  _getDataUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idLoggedUser = loggedUser.uid;

    _idUserReceiver = widget.contact.idUser;

    _getMessage();
  }

  Stream<QuerySnapshot> _getMessage() {
    _idUserReceiver = widget.contact.idUser;

    final stream = db
        .collection("Mensagem")
        .document(widget.idUser)
        .collection(_idUserReceiver)
        .orderBy("date", descending: false)
        .snapshots();

    stream.listen((data) {
      _controller.add(data);
      Timer(Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getDataUser();
  }

  @override
  Widget build(BuildContext context) {
    var stream = StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: [
                    Text("Carregando mensagens...",
                        style: TextStyle(color: Colors.white)),
                    CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    )
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot querySnapshot = snapshot.data;

              if (snapshot.hasError) {
                return Expanded(
                  child: Text("Erro ao carregar mensagens..."),
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: querySnapshot.documents.length,
                      itemBuilder: (context, index) {
                        List<DocumentSnapshot> messages =
                            querySnapshot.documents.toList();
                        DocumentSnapshot item = messages[index];

                        double widthContainer =
                            MediaQuery.of(context).size.width * 0.8;

                        Alignment alignment = Alignment.centerRight;
                        Color color = Color(0xff2075C1);
                        if (_idLoggedUser != item["idUser"]) {
                          alignment = Alignment.centerLeft;
                          color = Color(0xff090F93);
                        }
                        return Align(
                          alignment: alignment,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Container(
                                width: widthContainer,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(8)),
                                child: item["type"] == "text"
                                    ? Text(
                                        item["message"],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      )
                                    : Image.network(item["urlImage"])),
                          ),
                        );
                      }),
                );
              }
              break;
          }
        });
    var boxMessage = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: _controllerMessage,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Digite uma mensagem...",
                      prefixIcon: IconButton(
                          icon: _upImage == true
                              ? CircularProgressIndicator()
                              : Icon(
                                  Icons.camera_alt,
                                  color: Color(0xff090F93),
                                ),
                          onPressed: _sendImage)),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff090F93),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: _sendMessage,
          )
        ],
      ),
    );

    // var listView = Expanded(
    //   child: ListView.builder(
    //       itemCount: listMessage.length,
    //       itemBuilder: (context, index) {
    //         return Align(
    //           alignment: Alignment.centerRight,
    //           child: Padding(
    //             padding: EdgeInsets.all(6),
    //             child: Container(
    //               padding: EdgeInsets.all(16),
    //               decoration: BoxDecoration(
    //                   color: Color(0xffD2FFA5),
    //                   borderRadius: BorderRadius.circular(8)),
    //               child: Text(
    //                 listMessage[index],
    //                 style: TextStyle(
    //                   fontSize: 18,
    //                 ),
    //               ),
    //             ),
    //           ),
    //         );
    //       }),
    // );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff050A6A),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.contact.urlImage),
            ),
            SizedBox(width: 10),
            Text(widget.contact.name),
          ],
        ),
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
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Container(
            child: Column(
              children: [
                stream,
                boxMessage,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
