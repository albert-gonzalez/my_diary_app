import 'package:flutter/material.dart';
import 'package:my_diary/generated/l10n.dart';
import 'package:my_diary/user/models/user.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  bool signingIn = false;

  @override
  void initState() {
    super.initState();

    _signInSilentlyWithGoogle();
  }

  List<Widget> renderButtons(User user) {
    if (signingIn || user.isLogged) {
      return [];
    }
    
    return [
      _renderSignInButton(
        onPressed: () => _signInWithGoogle(user),
        icon: Image.asset('assets/google_icon.png', width: 28,),
        label: S.of(context).signInWithGoogle,
      ),
      const SizedBox(height: 10),
      _renderSignInButton(
        onPressed: () => _signInAnonymously(user, context),
        icon: const Icon(Icons.person, color: Colors.black),
        label: S.of(context).signInAnonymously,
      )
    ];
  }

  Widget _renderSignInButton({required Widget icon, required String label, required VoidCallback onPressed}) => ElevatedButton.icon(
    onPressed: onPressed,
    icon: icon,
    label: Text(label, style: const TextStyle(color: Colors.black)),
    style: ElevatedButton.styleFrom(primary: Colors.white, fixedSize: const Size.fromWidth(220), padding: const EdgeInsets.symmetric(vertical: 10)),
  );

  Future<void> _signInSilentlyWithGoogle() async {
    User user = context.read();
    setState(() => signingIn = true);
    try {
      await user.signInSilentlyWithGoogle();
    } finally {
      setState(() => signingIn = false);
    }
  }

  Future<void> _signInWithGoogle(User user) async {
    setState(() => signingIn = true);
    try {
      await user.signInWithGoogle();
    } finally {
      setState(() => signingIn = false);
    }
  }

  void _signInAnonymously(User user, BuildContext context) {
      user.signInAsAnonymous(context);
  }

  Widget _buildBody() {
    final User user = context.watch<User>();

    if (user.isLogged) {
      Future.microtask(() => Navigator.of(context).pushReplacementNamed('/entry/list'));
    }
    
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Icon(Icons.menu_book, size: 64, color: Theme.of(context).primaryColor),
          const SizedBox(height: 20,)
        ])),
        Expanded(child: Column(children: renderButtons(user),))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());

  }
}