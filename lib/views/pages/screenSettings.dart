import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ScreenSettings extends StatefulWidget {
  @override
  _ScreenSettingsState createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends State<ScreenSettings> {
  TextEditingController _textEditingControllerName = TextEditingController();
  File _image;
  String _idLoggedUser;
  bool _upImage = false;
  String _urlImagePERFIL;

  Future _selectedImage(String image) async {
    File selectedImage;
    final _picker = ImagePicker();

    switch (image) {
      case "camera":
        final _pickedFile = await _picker.getImage(source: ImageSource.camera);
        selectedImage = File(_pickedFile.path);
        break;
      case "galeria":
        final _pickedFile = await _picker.getImage(source: ImageSource.gallery);
        selectedImage = File(_pickedFile.path);
        break;
      default:
    }
    setState(() {
      _image = selectedImage;
      if (image != null) {
        _upImage = true;
        uploadImagePerfil();
      }
    });
  }

  Future uploadImagePerfil() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference folder = storage.ref();
    StorageReference file =
        folder.child("perfil").child(_idLoggedUser + ".jpg");

    //Upload da imagem
    StorageUploadTask task = file.putFile(_image);

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
    _updateUrlImagePERFIL(url);
    setState(() {
      _urlImagePERFIL = url;
    });
  }

  _updateNamePERFIL() {
    String name = _textEditingControllerName.text;
    Firestore db = Firestore.instance;

    Map<String, dynamic> updateData = {"name": name};

    db.collection("Usuarios").document(_idLoggedUser).updateData(updateData);
  }

  _updateUrlImagePERFIL(String url) {
    Firestore db = Firestore.instance;

    Map<String, dynamic> updateData = {"urlImage": url};

    db.collection("Usuarios").document(_idLoggedUser).updateData(updateData);
  }

  _getDataUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idLoggedUser = loggedUser.uid;

    Firestore db = Firestore.instance;

    DocumentSnapshot snapshot =
        await db.collection("Usuarios").document(_idLoggedUser).get();

    Map<String, dynamic> data = snapshot.data;
    _textEditingControllerName.text = data["name"];

    if (data["urlImage"] != null) {
      setState(() {
        _urlImagePERFIL = data["urlImage"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getDataUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff050A6A),
        centerTitle: true,
        title: Text("Configurações"),
      ),
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //Carregando
                _upImage
                    ? Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: CircularProgressIndicator())
                    : Container(),
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage: _urlImagePERFIL != null
                        ? NetworkImage(_urlImagePERFIL)
                        : null),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color(0xff050A6A),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                      ),
                      onPressed: () {
                        _selectedImage("camera");
                      },
                      child: Text(
                        "Câmera",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(width: 30),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color(0xff050A6A),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                      ),
                      onPressed: () {
                        _selectedImage("galeria");
                      },
                      child: Text(
                        "Galeria",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: _textEditingControllerName,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: ""),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color(0xff050A6A),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                  onPressed: () {
                    _updateNamePERFIL();
                  },
                  child: Text(
                    "Salvar Alterações",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
