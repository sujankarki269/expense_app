import 'package:expense_app/services/auth.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_app/wrapper.dart';

import 'package:provider/provider.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild.unfocus();
        }
      },
      child: StreamProvider<FirebaseUser>(
        create: (_) => AuthService().user,
        child: MaterialApp(
          home: Wrapper(),
          theme: ThemeData(
            primaryColor: Colors.red[900],
            accentColor: Colors.blueGrey,
            fontFamily: 'Andika',
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
