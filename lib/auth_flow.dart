// This file contains pages used after account creation

// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'my_app_state.dart';
import 'themes.dart';

// This is the verify email page
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
      timer = Timer.periodic(
        const Duration(seconds: 5),
        (context) => checkEmailVerified(),
      );
    }
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
        ? AppNav(newUser: newUser)
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
    } catch (error) {
      showTextSnackBar('Error sending email: $error');
    }
  }

// This method checks whether the user is verified
// It reloads the current user's data, and if they are verified, cancels the timer
  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      newUser = true;
      emailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (emailVerified) {
      timer?.cancel();
    }
  }
}

// This is the error message page
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
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
                // The user can sign out and retry processes
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
}

// This class manages navigation after verified user logs in or a new user verifies their email
class AppNav extends StatefulWidget {
  const AppNav({super.key, required this.newUser});
  final bool newUser;

  @override
  State<AppNav> createState() => _AppNavState();
}

class _AppNavState extends State<AppNav> {
  late Future<dynamic> _future;
  // An initState() is used so these methods are not called multiple times
  @override
  void initState() {
    super.initState();
    Future<dynamic> initApp() async {
      await Future.delayed(const Duration(seconds: 5));
      await FirebaseAuth.instance.currentUser!.reload();
      await context.read<MyAppState>().readHintPages();
      if (widget.newUser) {
        await context.read<MyAppState>().createUserInDB();
      }
      await context.read<MyAppState>().readUser();

      context.read<MyAppState>().navigateTo(0);
      return Future.value();
    }

    _future = initApp();
  }

  @override
  Widget build(BuildContext context) {
    // The asynchronous methods are called here
    // Then, once the user and app are set up, the app navigates to the home page
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorPage(error: snapshot.error);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return animatedLogo(context, true);
        } else {
          return MyHomePage(
            newUser: widget.newUser,
            title: '5 Minute संस्कृतम् ।',
          );
        }
      },
    );
  }
}
