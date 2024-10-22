// This file contains smaller widgets used during the user authentication flow

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'auth_pages.dart';
import 'main.dart';
import 'themes.dart';

// This widget displays and handles login
class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key, required this.switchToSignUp});

  // This void call
  final VoidCallback switchToSignUp;

  @override
  // ignore: library_private_types_in_public_api
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // These string variables are used to display error text below the username and password
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // This is the header
            Text(
              'Sign in',
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
              // This is where the user enters their email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorMaxLines: 3,
                  errorText:
                      _emailErrorMessage.isEmpty ? null : _emailErrorMessage,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              // This is where the user enters their password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorMaxLines: 3,
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
              // This is the sign in button
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    signIn();
                  }
                },
                child: const Text('Sign in'),
              ),
              const SizedBox(height: 10),
              // This is the forgot password button
              MouseRegion(
                cursor: WidgetStateMouseCursor.clickable,
                child: GestureDetector(
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: ConstColors.shade,
                          decoration: TextDecoration.underline,
                          decorationColor: ConstColors.shade,
                        ),
                  ),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ForgotPasswordPage(),
                  )),
                ),
              ),
              const SizedBox(height: 5),
              // This is the button to switch to the sign up page
              RichText(
                text: TextSpan(
                  text: 'No account? ',
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.switchToSignUp,
                      text: 'Sign up',
                      style: const TextStyle(
                        color: ConstColors.shade,
                        decoration: TextDecoration.underline,
                        decorationColor: ConstColors.shade,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// This method allows the user to sign in
  Future<void> signIn() async {
    // After this method starts running, a loading page is shown
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Here, the user is signed in Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (error) {
      // Here, an error message is shown based on the type of error given
      if (error.code == 'invalid-email') {
        setState(() {
          _emailErrorMessage = 'The email address is badly formatted.';
          _passwordErrorMessage = '';
        });
      } else if (error.code == 'invalid-credential') {
        setState(() {
          _emailErrorMessage = '';
          _passwordErrorMessage =
              'No user found with the given combination of email and credentials.';
        });
      } else if (error.code == 'user-disabled') {
        setState(() {
          _emailErrorMessage =
              'The user account associated with this email is disabled.';
          _passwordErrorMessage = '';
        });
      } else {
        setState(() {
          _emailErrorMessage = '';
          _passwordErrorMessage = error.message ?? 'An unknown error occurred.';
        });
      }
    } catch (error) {
      setState(() {
        _emailErrorMessage = '';
        _passwordErrorMessage = error.toString();
      });
    }

    // Once this method is completed, the loading page is no longer shown
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}

// This widget displays and handles signing up
class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key, required this.switchToSignIn});

  final VoidCallback switchToSignIn;

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  String _emailErrorMessage = '';
  String _passwordErrorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // This is the header
            Text(
              'Sign up',
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
              // This is where the user enters their name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              // This is where the user enters their email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorMaxLines: 3,
                  errorText:
                      _emailErrorMessage.isEmpty ? null : _emailErrorMessage,
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              // This is where the user enters their password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorMaxLines: 3,
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
              // This is where the user confirms their password
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value == _passwordController.text) {
                    return null;
                  }
                  return 'Passwords do not match';
                },
              ),
              const SizedBox(height: 30),
              // This is the sign up button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    signUp();
                  }
                },
                child: const Text('Sign up'),
              ),
              const SizedBox(height: 10),
              // This is the button to switch to logging in
              RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.switchToSignIn,
                      text: 'Sign in',
                      style: const TextStyle(
                        color: ConstColors.shade,
                        decoration: TextDecoration.underline,
                        decorationColor: ConstColors.shade,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// This method creates a new user account
  void signUp() async {
    // After the method is called, a loading page is shown
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Here, a new account is created in Firebase Auth
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Here, a new user is created locally
      // ignore: use_build_context_synchronously
      context.read<MyAppState>().updateUserName(_nameController.text.trim());
    } on FirebaseAuthException catch (error) {
      // Here, an error message is shown based on the type of error given
      if (error.code == 'invalid-email') {
        setState(() {
          _emailErrorMessage = 'The email address is badly formatted.';
          _passwordErrorMessage = '';
        });
      } else if (error.code == 'email-already-in-use') {
        setState(() {
          _emailErrorMessage = 'This email is already in use.';
          _passwordErrorMessage = '';
        });
      } else {
        setState(() {
          _emailErrorMessage = '';
          _passwordErrorMessage = error.message ?? 'An unknown error occurred.';
        });
      }
    } catch (error) {
      setState(() {
        _emailErrorMessage = '';
        _passwordErrorMessage = error.toString();
      });
    }

    // Once this method is complete, the loading page is no longer shown
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
