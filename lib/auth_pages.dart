// This file contains the main pages used in user authentication

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'main.dart';
import 'themes.dart';

// This class manages root authentication navigation
class AuthNav extends StatefulWidget {
  const AuthNav({super.key});

  @override
  State<AuthNav> createState() => _AuthNavState();
}

class _AuthNavState extends State<AuthNav> {
  @override
  Widget build(BuildContext context) {
    // Root-level navigation depends on a stream of user authentication state changes
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // If there's an error, display the error message page
            return errorMessage(snapshot.error, context);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            // If waiting, display a non-animated-logo loading page
            return animatedLogo(context, false);
          } else if (snapshot.hasData) {
            // If the user is signed in, send navigation to the verify email page
            return const VerifyEmailPage();
          } else {
            // Else, take the user to the authentication page (log in or sign up)
            return const AuthPage();
          }
        });
  }
}

// This is the error message page
Widget errorMessage(Object? error, BuildContext context) {
  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: FloatingBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 20),
              Text(
                'Oops! Something went wrong.',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'क्षम्यताम्! We apologize for the inconvenience.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Error: $error',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Return to Login'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// This is the authentication page, where the user can log in, create a new account, etc.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // The variable and method manage state based on whether the user is logging in or signing up
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
            // This is the welcome message and logo
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 25, 0, 5),
              child: Text(
                'Welcome to ',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            logo,
            // This is the center box that will either contain the log in or sign up widget
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: FloatingBox(
                    child: login
                        ? LoginWidget(switchToSignUp: toggle)
                        : SignUpWidget(switchtoSignIn: toggle),
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

// This is the forgot password page
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
      // A simple app bar that lets the user go back
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
                    // This is where the user enters their email to send the reset password link to.
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

// This method sends a link to the user's email to reset their password
  Future resetPassword() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // A snackbar is shown based on whether the operation is successful
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showTextSnackBar("A reset password email was sent.");

      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    } on Exception catch (error) {
      showTextSnackBar(
        "Error sending email: $error",
      );
      // Navigating back to the authentication page
      navigatorKey.currentState!.pop();
    }
  }
}

// Tis is the verify email page
class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool newUser = false;
  bool emailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  // Here, values are initialized, and an initial verification email is sent
  // The timer checks whether the user's email has been verified every 5 seconds
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
        // If the email is verified, then they are sent to the verified page, with further navigation logic
        ? VerifiedHomePage(newUser: newUser)
        // Else, a simple page is shown, where users can resend a verification email or cancel
        : Scaffold(
            // A simple app bar that lets the user go back
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
                            // Users can only send a verification email every 5 seconds
                            canResendEmail ? sendVerificationEmail : null,
                        icon: const Icon(Icons.email),
                        label: const Text('Resend Email'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          // The cancel button just signs the user out, but an account is created
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

// This method sends the user a verification email
// If an error comes up, it displays a snack bar
  Future sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      // After an email is sent, the user must wait 5 seconds before sending another one
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } on Exception catch (error) {
      showTextSnackBar('Error sending email: $error');
    }
  }

// This method checks whether the user is verified
// It reloads the current user's data, and if they are verfied, cancels the timer
  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      emailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      newUser = true;
    });

    if (emailVerified) {
      timer?.cancel();
    }
  }
}
