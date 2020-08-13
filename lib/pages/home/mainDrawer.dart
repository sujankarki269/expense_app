import 'package:community_material_icon/community_material_icon.dart';
import 'package:expense_app/services/auth.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_app/models/period.dart';
import 'package:expense_app/models/user.dart';
import 'package:expense_app/pages/categories/categoriesList.dart';
import 'package:expense_app/pages/periods/periodsList.dart';
import 'package:expense_app/pages/preferences/preferencesForm.dart';
import 'package:expense_app/pages/recurringTransactions/recurringTransactionsList.dart';
import 'package:expense_app/pages/suggestions/suggestionsList.dart';

import 'package:expense_app/services/databaseWrapper.dart';
import 'package:expense_app/shared/library.dart';
import 'package:expense_app/shared/components.dart';
import 'package:provider/provider.dart';

class MainDrawer extends StatefulWidget {
  final FirebaseUser user;
  final Function openPage;

  MainDrawer({this.user, this.openPage});

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final AuthService _auth = AuthService();
  User userInfo;

  @override
  void initState() {
    super.initState();
    DatabaseWrapper(widget.user.uid).getUser().then((user) {
      setState(() => userInfo = user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(userInfo != null ? userInfo.fullname : ''),
            accountEmail: Text(userInfo != null ? userInfo.email : ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userInfo != null ? userInfo.fullname[0] : '',
                style: TextStyle(
                  fontSize: 40.0,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Home'),
            leading: Icon(CommunityMaterialIcons.home),
            onTap: () => goHome(context),
          ),
          ListTile(
            title: Text('Categories'),
            leading: Icon(CommunityMaterialIcons.shape),
            onTap: () => widget.openPage(
              CategoriesList(
                user: widget.user,
                openPage: widget.openPage,
              ),
            ),
          ),
          ListTile(
            title: Text('Periods'),
            leading: Icon(CommunityMaterialIcons.calendar_range),
            onTap: () => widget.openPage(
              FutureProvider<List<Period>>(
                create: (_) => DatabaseWrapper(widget.user.uid).getPeriods(),
                child: PeriodsList(
                  user: widget.user,
                  openPage: widget.openPage,
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Recurring Transactions'),
            leading: Icon(CommunityMaterialIcons.history),
            onTap: () => widget.openPage(
              RecurringTransactionsList(
                user: widget.user,
                openPage: widget.openPage,
              ),
            ),
          ),
          ListTile(
            title: Text('Suggestions'),
            leading: Icon(CommunityMaterialIcons.lightbulb_outline),
            onTap: () => widget.openPage(
              SuggestionsList(
                user: widget.user,
                openPage: widget.openPage,
              ),
            ),
          ),
          ListTile(
            title: Text('Preferences'),
            leading: Icon(CommunityMaterialIcons.tune),
            onTap: () => widget.openPage(
              PreferencesForm(user: widget.user, openPage: widget.openPage),
            ),
          ),
          ListTile(
            title: Text('Sign Out'),
            leading: Icon(CommunityMaterialIcons.logout),
            onTap: () async {
              bool hasBeenConfirmed = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Alert('You will be signed out.');
                    },
                  ) ??
                  false;
              if (hasBeenConfirmed) {
                goHome(context);
                _auth.signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
