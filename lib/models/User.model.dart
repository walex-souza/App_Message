class User{
  String _name;
  String _email;
  String _password;

  User();

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      "name" : this.name,
      "email" : this.email
    };
    return map;
  }

  
 String get name => this._name;

 set name(String value) => this._name = value;

 String get email => this._email;

 set email(String value) => this._email = value;

 String get password => this._password;

 set password(String value) => this._password = value;



}