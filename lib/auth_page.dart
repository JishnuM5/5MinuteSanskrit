import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_widgets.dart';
import 'main.dart';
import 'my_app_state.dart';
import 'themes.dart';

class AuthNav extends StatefulWidget {
  const AuthNav({super.key});

  @override
  State<AuthNav> createState() => _AuthNavState();
}

class _AuthNavState extends State<AuthNav> {
  Future? myFuture;

  @override
  void initState() {
    super.initState();
    myFuture = context.read<MyAppState>().readQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Material(
              child: animatedLogo(context, true),
            );
          } else if ((snapshot.hasError)) {
            return errorMessage(snapshot.error);
          } else {
            return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return errorMessage(snapshot.error);
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return animatedLogo(context, false);
                  } else if (snapshot.hasData) {
                    return FutureBuilder(
                        future: context.read<MyAppState>().readUser(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return errorMessage(snapshot.error);
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return animatedLogo(context, false);
                          } else {
                            return const MyHomePage(
                                title: '5 Minute संस्कृतम्');
                          }
                        });
                  } else {
                    return const AuthPage();
                  }
                });
          }
        });
  }
}

Widget errorMessage(Object? error) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Text(
          'Hmm. It looks like something went wrong. क्षम्यताम्!\nError: $error',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool login = true;
  void toggle() => setState(() {
        login = !login;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 25, 0, 5),
              child: Text(
                'Welcome to ',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            logo,
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: FloatingBox(
                    child: login
                        ? LoginWidget(onClickedSignIn: toggle)
                        : SignUpWidget(onClickedSignUp: toggle),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// An animation for the title I was playing with but never implemented.
class AnimatedTitle extends StatelessWidget {
  const AnimatedTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      isRepeatingAnimation: false,
      animatedTexts: [
        FadeAnimatedText(
          'Welcome to',
          textStyle: Theme.of(context).textTheme.displayLarge,
          fadeInEnd: 2,
          fadeOutBegin: double.maxFinite,
        ),
      ],
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(15),
      ),
    );
  }
}
