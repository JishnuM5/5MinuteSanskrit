// This file contains all pages and features for the profile page

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanskrit_web_app/my_app_state.dart';
import 'themes.dart';

// This class is the profile page of the application
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool nameChange = false;

  @override
  Widget build(BuildContext context) {
    // The name controller is inialized with the user's current name
    _nameController = TextEditingController(
      text: context.watch<MyAppState>().appUser.name,
    );
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // This is the header
            Text('Profile', style: Theme.of(context).textTheme.displayLarge),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Divider(),
            ),
            // This is the first section of the profile page, showing the current email
            // It also gives the user the option to sign out
            Padding(
              padding: const EdgeInsets.all(20),
              child: FloatingBox(
                child: Column(
                  children: [
                    Text(
                      'Signed in as',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      user!.email!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    // This is the sign out button
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        context.read<MyAppState>().navigateTo(0);
                      },
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
            // This is the second section of the profile page, with updatable profile fields
            Padding(
              padding: const EdgeInsets.all(20),
              child: FloatingBox(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Changing the user's name
                      Text(
                        'Name',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      TextFormField(
                        controller: _nameController,
                        onChanged: (value) => nameChange = true,
                        decoration: denseInputDecor('Enter new name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Changing the user's password
                      Text(
                        'New Password',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: denseInputDecor('Enter new password'),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.trim().length < 6) {
                            return 'Password should be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Confirming the new password if changed
                      Text(
                        'Confirm Password',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: denseInputDecor('Confirm new password'),
                        validator: (value) {
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),
                      // This button saves and updates the user's data when clicked
                      ElevatedButton(
                        onPressed: () async {
                          // User fields are validated
                          if (_formKey.currentState!.validate()) {
                            // Based on what the user has changed, data is updated
                            // A snack bar is showed with either a success or error message
                            try {
                              String newPassword =
                                  _newPasswordController.text.trim();
                              List<Future> updates = [];

                              if (nameChange) {
                                updates.add(
                                  context.read<MyAppState>().updateUser(
                                        _nameController.text.trim(),
                                      ),
                                );
                              }
                              if (newPassword.isNotEmpty) {
                                updates.add(user.updatePassword(newPassword));
                              }
                              await Future.wait(updates);
                              showTextSnackBar('Changes saved.');
                            } catch (error) {
                              showTextSnackBar('Error saving data: $error');
                            }
                          }
                        },
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // This is the about screen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('About Project'),
                        content: const SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Jishnu Mehta\nAdvanced Programming Topics\nPeriod 2\nJune 7, 2024',
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                '5 Minute संस्कृतम् ।\nA quiz application to supplement Sanskrit learning\nCreated with Flutter, using Github, Firebase, and VS Code',
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('About Project'),
              ),
            ),
            // This is the delete account button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // This is a confirmation dialog
                      return AlertDialog(
                        title: const Text('Delete Account'),
                        content: const Text(
                            'Are you sure you want to delete your account? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            // If they confirm, the user account and database data are deleted
                            onPressed: () {
                              deleteUserData()
                                  .then(
                                (value) =>
                                    (showTextSnackBar("User account deleted")),
                              )
                                  .catchError((error) {
                                (
                                  showTextSnackBar(
                                      "Error deleting user: $error"),
                                );
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                ),
                child: const Text('Delete Account'),
              ),
            )
          ],
        ),
      ),
    );
  }

  // This is the input decouration used for text fields on the profile page
  InputDecoration denseInputDecor(String hintText) {
    return InputDecoration(
      hintText: hintText,
      isDense: true,
      contentPadding: const EdgeInsets.only(bottom: 5, top: 3),
    );
  }

  // This method deletes all the user's data from the database
  // Errors are handled in the paret widget
  Future deleteUserData() {
    try {
      String email = FirebaseAuth.instance.currentUser!.email!;
      final userRef = FirebaseFirestore.instance.collection('users').doc(email);
      return FirebaseAuth.instance.currentUser!
          .delete()
          .then((value) => userRef.delete())
          .catchError(
            (error) => Future.error("Error deleting user: $error"),
          );
    } catch (error) {
      return Future.error('$error');
    }
  }
}
