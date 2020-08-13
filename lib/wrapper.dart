import 'package:expense_app/pages/auth/authWrapper.dart';
import 'package:expense_app/pages/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    dynamic _user = Provider.of<FirebaseUser>(context);

    if (_user != null) {
      return Home(user: _user);
    } else {
      return AuthWrapper();
    }
  }
}
