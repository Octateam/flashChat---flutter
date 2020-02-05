import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;  
  // creating a firebase instance to add the new user

  bool showSpinner = false;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        //ModalProgressHUD is for the spinner, and we covered the 
        //whole body with it because it is meant to overlap the screen

        inAsyncCall: showSpinner,
        //inAsyncCall is required for the spinner 
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your email')),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password')),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Register',
                color: Colors.blueAccent,
                onPressed:() async { 
                  // async and await because we have to wait to validate 
                  //that the user is registered before going to the chats

                  setState(() {
                    showSpinner = true;
                  });

                  //When the user presses the register, it starts spining
                  //till the authentication finished
                  
                  try {
                 final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password );
                 //adding the new user's registration email and password 
                 //to the firebase instance initially created
                 if (newUser != null) {
                   // checking if the user is already registered and if yes
                   //navigating to the chat screen
                   Navigator.pushNamed(context, ChatScreen.id);
                 }
                 setState(() {
                   showSpinner = false;
                 });
                  } catch (e) {
                    print (e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
