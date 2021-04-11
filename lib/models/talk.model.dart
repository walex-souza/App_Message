import 'package:cloud_firestore/cloud_firestore.dart';

class Talk {
  String _idRementente;
  String _idDestinatario;
  String _name;
  String _message;
  String _image;
  String _typeMessage;

  Talk();

  save() async {
    Firestore db = Firestore.instance;
    await db
        .collection("Conversas")
        .document(this._idRementente)
        .collection("ultima_conversa")
        .document(this.idDestinatario)
        .setData(
          this.toMap(),
        );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idRementente": this.idRementente,
      "idDestinatario": this.idDestinatario,
      "message": this.message,
      "name": this.name,
      "image": this.image,
      "typeMessage": this.typeMessage,
    };
    return map;
  }

  String get idRementente => this._idRementente;

  set idRementente(String value) => this._idRementente = value;

  get idDestinatario => this._idDestinatario;

  set idDestinatario(value) => this._idDestinatario = value;

  String get name => this._name;

  set name(String value) => this._name = value;

  String get message => this._message;

  set message(String value) => this._message = value;

  String get image => this._image;

  set image(String value) => this._image = value;

  get typeMessage => this._typeMessage;

  set typeMessage(value) => this._typeMessage = value;
}
