// This file contains the main pages used by a user for account sign-in or creation

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_flow.dart';
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
            return ErrorPage(error: snapshot.error);
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
            logo(CrossAxisAlignment.center),
            // This is the center box that will either contain the log in or sign up widget
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: FloatingBox(
                    child: SingleChildScrollView(
                      child: login
                          ? LoginWidget(switchToSignUp: toggle)
                          : SignUpWidget(switchToSignIn: toggle),
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
                      'Receive an email to\nreset your password',
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
                      label: const Text('Reset Password'),
                    ),
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
    } catch (error) {
      showTextSnackBar(
        "Error sending email: $error",
      );
      // Navigating back to the authentication page
      navigatorKey.currentState!.pop();
    }
  }
}

class PilotLevelPopup extends StatefulWidget {
  const PilotLevelPopup({super.key});

  @override
  State<PilotLevelPopup> createState() => _PilotLevelPopupState();
}

class _PilotLevelPopupState extends State<PilotLevelPopup> {
  String code = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ConstColors.background,
      child: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'Select Your Quiz Level',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 10),

                // Explanation
                const Text(
                  'Select your quiz level to receive appropriate quizzes during the pilot program. You\'ll be logged out, and your account will update the next time you log in.',
                ),
                const SizedBox(height: 20),

                // Level options
                buildLevelOption(
                  context,
                  title: 'Beginner',
                  icon: Icons.star,
                  tooltip:
                      'Start with the basics: conversation skills, telling the time, and action words',
                  levelCode: 'beginner',
                ),
                const SizedBox(height: 10),
                buildLevelOption(
                  context,
                  title: 'Advanced',
                  icon: Icons.school,
                  tooltip:
                      'Challenge yourself with पुंलिङ्ग विभक्तिः and an intro to सन्धिः/संयोगः',
                  levelCode: 'advanced',
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: code == ''
                      ? null
                      : () async {
                          await updateLevel(code);
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLevelOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String tooltip,
    required String levelCode,
  }) {
    Color foreground = code == levelCode ? ConstColors.shade : Colors.grey;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => setState(() {
          code = levelCode;
        }),
        child: Container(
          decoration: BoxDecoration(
            color: code == levelCode ? ConstColors.primary : ConstColors.grey,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: foreground, width: 3),
          ),
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Icon(icon, color: foreground, size: 30),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: foreground,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  updateLevel(String code) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(
          FirebaseAuth.instance.currentUser!.email!,
        );
    try {
      await userRef.update({'code': code});
      await FirebaseAuth.instance.signOut();
      return Future.value(code);
    } catch (error) {
      showTextSnackBar('Error updating level: $error');
    }
  }
}
