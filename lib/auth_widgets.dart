import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key, required this.onClickedSignIn});

  final VoidCallback onClickedSignIn;

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
    return Column(
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
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignIn,
                      text: "Sign up",
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        decoration: TextDecoration.underline,
                        decorationColor: Theme.of(context).primaryColorLight,
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
      } else if (e.code == 'user-disabled') {
        setState(() {
          _emailErrorMessage =
              'The user account associated with this email is disabled.';
          _passwordErrorMessage = '';
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

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key, required this.onClickedSignUp});

  final VoidCallback onClickedSignUp;

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
            Text(
              "Sign up",
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Sign in with Firebase Auth
                    signUp();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('Sign up'),
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = widget.onClickedSignUp,
                      text: "Sign in",
                      style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        decoration: TextDecoration.underline,
                        decorationColor: Theme.of(context).primaryColorLight,
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

  void signUp() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(_emailController.text.trim());

      await userDoc.set({'name': _nameController.text.trim()});
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        setState(() {
          _emailErrorMessage = 'The email address is badly formatted.';
          _passwordErrorMessage = '';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _emailErrorMessage = 'This email is already in use.';
          _passwordErrorMessage = '';
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
