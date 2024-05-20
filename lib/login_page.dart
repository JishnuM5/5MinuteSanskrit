import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'quiz_page.dart';
import 'themes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future? myFuture;

  @override
  void initState() {
    super.initState();
    myFuture = Provider.of<MyQuizState>(context, listen: false).readQuiz();
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
                    return const MyHomePage(title: '5 Minute संस्कृतम्');
                  } else {
                    return const LoginWidget();
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
          "Hmm. It looks like something went wrong. क्षम्यताम्!\nError: $error",
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _emailErrorMessage = '';
  String _passwordErrorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 25, 0, 5),
              child: Text(
                "Welcome to ",
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            logo,
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Sign in",
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  errorText: _emailErrorMessage.isEmpty
                                      ? null
                                      : _emailErrorMessage,
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  errorText: _passwordErrorMessage.isEmpty
                                      ? null
                                      : _passwordErrorMessage,
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Sign in with Firebase Auth
                                    signIn();
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text('Sign in'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              RichText(
                                text: TextSpan(
                                  text: "No account? ",
                                  style: Theme.of(context).textTheme.bodySmall,
                                  children: [
                                    TextSpan(
                                      text: "Sign up",
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        decoration: TextDecoration.underline,
                                        decorationColor:
                                            Theme.of(context).primaryColorLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        setState(() {
          _emailErrorMessage = 'The email address is badly formatted.';
          _passwordErrorMessage = '';
        });
      } else if (e.code == 'invalid-credential') {
        setState(() {
          _emailErrorMessage = '';
          _passwordErrorMessage =
              'No user found with the given combination of email and credentials.';
        });
      } else {
        setState(() {
          _emailErrorMessage = '';
          _passwordErrorMessage = e.message ?? 'An unknown error occurred.';
        });
      }
    } catch (error) {
      setState(() {
        _emailErrorMessage = '';
        _passwordErrorMessage = error.toString();
      });
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
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
