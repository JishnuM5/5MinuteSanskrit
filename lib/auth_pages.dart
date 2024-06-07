import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'main.dart';
import 'themes.dart';

class AuthNav extends StatefulWidget {
  const AuthNav({super.key});

  @override
  State<AuthNav> createState() => _AuthNavState();
}

class _AuthNavState extends State<AuthNav> {
  Future? myFuture;
  bool newUser = false;
  void isNewUser() => (newUser = !newUser);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return errorMessage(snapshot.error, context);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return animatedLogo(context, false);
          } else if (snapshot.hasData) {
            return VerifyEmailPage(newUser: newUser);
          } else {
            return AuthPage(
              isNewUser: isNewUser,
            );
          }
        });
    // }
    // });
  }
}

Widget errorMessage(Object? error, BuildContext context) {
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
  const AuthPage({super.key, required this.isNewUser});
  final VoidCallback isNewUser;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool login = true;
  void toggle() => setState(() {
        login = !login;
        widget.isNewUser();
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
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Reset Password'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: FloatingBox(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Text(
                      'Recieve an email to\nreset your password',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        errorMaxLines: 3,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                        onPressed: resetPassword,
                        icon: const Icon(Icons.email_outlined),
                        label: const Text('Reset Password')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showTextSnackBar("A reset password email was sent.");

      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } on Exception catch (error) {
      showTextSnackBar(
        "Error sending email: $error",
      );
      navigatorKey.currentState!.pop();
    }
  }
}

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key, required this.newUser});
  final bool newUser;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool emailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    emailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!emailVerified) {
      sendVerificationEmail();
    }

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (context) => checkEmailVerified(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (emailVerified)
        ? VerifiedHomePage(newUser: widget.newUser)
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('Verify Email'),
              leading: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FloatingBox(
                      child: Column(
                    children: [
                      const Text('A verification email has been sent.'),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed:
                            canResendEmail ? sendVerificationEmail : null,
                        icon: const Icon(Icons.email),
                        label: const Text('Resend Email'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        child: const Text('Cancel'),
                      )
                    ],
                  )),
                ],
              ),
            ),
          );
  }

  Future sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } on Exception catch (error) {
      showTextSnackBar('Error sending email: $error');
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      emailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (emailVerified) {
      timer?.cancel();
    }
  }
}
