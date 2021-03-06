import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/models/User.model.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //Controladores
  TextEditingController textEditingControllerName = TextEditingController();
  TextEditingController textEditingControllerEmail = TextEditingController();
  TextEditingController textEditingControllerPassword = TextEditingController();
  String messageErroRegister = "";

  _validateRegister() {
    //recuperar dados dos campos
    String name = textEditingControllerName.text;
    String email = textEditingControllerEmail.text;
    String password = textEditingControllerPassword.text;

    if (name.isNotEmpty) {
      if (email.isNotEmpty && email.contains("@")) {
        if (password.isNotEmpty && password.length > 6) {
          setState(() {
            messageErroRegister = "";
          });

          User user = User();
          user.name = name;
          user.email = email;
          user.password = password;

          _registerUser(user);
        } else {
          setState(() {
            messageErroRegister = "A senha deve conter mais de 6 caracteres";
          });
        }
      } else {
        setState(() {
          messageErroRegister = "Preencha o Email utilizando @";
        });
      }
    } else {
      setState(() {
        messageErroRegister = "Digite seu nome";
      });
    }
  }

  _registerUser(User user) {
    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    )
        .then((FirebaseUser) {
      Firestore db = Firestore.instance;
      db
          .collection("Usuarios")
          .document(FirebaseUser.uid)
          .setData(user.toMap());

      Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
    }).catchError((error) {
      setState(() {
        messageErroRegister = "Erro ao cadastrar usu??rio, verifique os campos!";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff050A6A),
        centerTitle: true,
        title: Text("Cadastro"),
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
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    "assets/logo_2.png",
                    height: 300,
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: textEditingControllerName,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32)),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Nome:"),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                      controller: textEditingControllerEmail,
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
                      controller: textEditingControllerPassword,
                      obscureText: true,
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
                            MaterialStateProperty.all<Color>(Color(0xff2075C1)),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
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
                        _validateRegister();
                      },
                      child: Text(
                        "Cadastrar",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Center(
                    child: Text(
                      messageErroRegister,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
