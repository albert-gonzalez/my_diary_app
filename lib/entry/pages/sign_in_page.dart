import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:my_diary/generated/l10n.dart';
import 'dart:convert' show json;

import 'package:my_diary/user/models/user.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();

    User user = context.read();
    user.signInSilentlyWithGoogle();
  }

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = 'People API gave a ${response.statusCode} '
            'response. Check logs for details.';
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data =
    json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = 'I see you know $namedContact!';
      } else {
        _contactText = 'No contacts to display.';
      }
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
          (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final Map<String, dynamic>? name = contact['names'].firstWhere(
            (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  Future<void> _signInWithGoogle(User user) async {
      await user.signInWithGoogle();
  }

  void _signInAnonymously(User user, BuildContext context) {
      user.signInAsAnonymous(context);
  }

  Widget _buildBody() {
    final User user = context.watch<User>();

    if (user.isLogged) {
      Future.microtask(() => Navigator.of(context).pushReplacementNamed('/entry/list'));
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [],
      );
    } else {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.menu_book, size: 64, color: Theme.of(context).primaryColor),
          ElevatedButton.icon(
            onPressed: () => _signInWithGoogle(user),
            icon: Image.asset('assets/google_icon.png', width: 28,),
            label: Text(S.of(context).signInWithGoogle, style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(primary: Colors.white, fixedSize: Size.fromWidth(220)),
          ),
          ElevatedButton.icon(
            onPressed: () => _signInAnonymously(user, context),
            icon: Icon(Icons.person, color: Colors.black),
            label: Text(S.of(context).signInAnonymously, style: TextStyle(color: Colors.black),),
            style: ElevatedButton.styleFrom(primary: Colors.white, fixedSize: Size.fromWidth(220)),
          )
        ],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());

  }
}