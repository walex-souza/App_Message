class User {
  String _idUser;
  String _name;
  String _email;
  String _password;
  String _urlImage;

  User();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "name": this.name,
      "email": this.email,
      "urlImage": this._urlImage
    };
    return map;
  }

  String get idUser => this._idUser;

  set idUser(String value) => this._idUser = value;

  String get name => this._name;

  set name(String value) => this._name = value;

  String get email => this._email;

  set email(String value) => this._email = value;

  String get password => this._password;

  set password(String value) => this._password = value;

  String get urlImage => this._urlImage;

  set urlImage(String value) => this._urlImage = value;
}
