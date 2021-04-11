import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/models/User.model.dart';
import 'package:whatsapp/views/register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _textEditingControllerEmail = TextEditingController();
  TextEditingController _textEditingControllerPassword =
      TextEditingController();
  String _messageErroRegister = "";

  _validateRegister() {
    //recuperar dados dos campos
    String email = _textEditingControllerEmail.text;
    String password = _textEditingControllerPassword.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (password.isNotEmpty) {
        setState(() {
          _messageErroRegister = "";
        });

        User user = User();
        user.email = email;
        user.password = password;

        _loginUser(user);
      } else {
        setState(() {
          _messageErroRegister = "Digite a senha corretamente!";
        });
      }
    } else {
      setState(() {
        _messageErroRegister = "Preencha o Email utilizando @";
      });
    }
  }

  _loginUser(User user) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .signInWithEmailAndPassword(
      email: user.email,
      password: user.password,
    )
        .then((FirebaseUser) {
      Navigator.pushReplacementNamed(context, "/home");
    }).catchError((error) {
      setState(() {
        _messageErroRegister = "Erro ao fazer login, verifique Email e senha!";
      });
    });
  }

  Future _checkUserLogin() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    //auth.signOut();

    FirebaseUser firebaseUser = await auth.currentUser();

    if (firebaseUser != null) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  @override
  void initState() {
    _checkUserLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff075E54),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  "assets/logo.png",
                  width: 200,
                  height: 150,
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _textEditingControllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "E-mail:"),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    obscureText: true,
                    controller: _textEditingControllerPassword,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32)),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Senha:"),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.green),
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
                      _validateRegister();
                    },
                    child: Text(
                      "Entrar",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      child: Text(
                        "Não tem conta ? Cadastre-se!",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Register(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Text(
                    _messageErroRegister,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
