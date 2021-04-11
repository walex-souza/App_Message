class Message {
  String _idUser;
  String _message;
  String _urlImage;
  String _date;

  //Define o tipo da mensagem, que pode ser "Texto" ou "Imagem"

  String _type;

  Message();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUser": this.idUser,
      "message": this.message,
      "urlImage": this.urlImage,
      "type": this.type,
      "date": this.date,
    };
    return map;
  }

  String get idUser => this._idUser;

  set idUser(String value) => this._idUser = value;

  get message => this._message;

  set message(value) => this._message = value;

  get urlImage => this._urlImage;

  set urlImage(value) => this._urlImage = value;

  get type => this._type;

  set type(value) => this._type = value;

  String get date => this._date;

  set date(String value) => this._date = value;
}
