import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:provider/provider.dart';

class Avatar extends StatelessWidget {
  const Avatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = context.watch();

    return user.isAnonymous || !user.isLogged
        ? LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) => Icon(Icons.person_sharp, size: constraints.maxWidth / 1.1))
        : GoogleUserCircleAvatar(
            identity: user.signInAccount!,
          );
  }
}
