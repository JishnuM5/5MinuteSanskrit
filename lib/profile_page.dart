// This file contains all pages and features for the profile page

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart';
import 'themes.dart';

// This class is the profile page of the application
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool nameChange = false;

  @override
  Widget build(BuildContext context) {
    // The name controller is initialized with the user's current name
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
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Divider(),
            ),
            // In the first section of the profile, users can view their email, which cannot be modified
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: FloatingBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signed in as',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      user!.email!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 10),
                    // This is the sign out button
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: const Text('Sign out'),
                    ),
                    const SizedBox(height: 25),
                    // In this section of the profile page, users can update profile fields
                    Form(
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
                          const SizedBox(height: 15),
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
                                    updates
                                        .add(user.updatePassword(newPassword));
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
                  ],
                ),
              ),
            ),
            // This widget will be implemented in the future for students to change their classroom info
            // It will contain the current classroom name and an option for students to change their classroom
            // Row(
            //   children: [
            //     Expanded(
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 20, vertical: 15),
            //         child: FloatingBox(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text(
            //                 'Classroom:',
            //                 style: Theme.of(context).textTheme.labelSmall,
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),

            // If the user has an admin email, show the add quiz widget
            (user.email == 'jishnu.mehta@samskritabharatiusa.org')
                ? const AddQuizWidget()
                : Container(),

            // This is the delete account button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
                                  .then((value) => showTextSnackBar(
                                        "User account deleted",
                                      ))
                                  .catchError(
                                    (error) => showTextSnackBar(
                                      "Error deleting user: $error",
                                    ),
                                  );
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                color: ConstColors.red,
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
                  backgroundColor: ConstColors.red,
                ),
                child: const Text('Delete Account'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // This method deletes all the user's data from the database
  // Errors are handled in the parent widget
  Future deleteUserData() {
    try {
      String email = FirebaseAuth.instance.currentUser!.email!;
      final userRef = FirebaseFirestore.instance.collection('users').doc(email);
      userRef.delete();
      return FirebaseAuth.instance.currentUser!.delete();
    } catch (error) {
      return Future.error('Error deleting user: $error');
    }
  }
}

// This widget allows users to write quizzes to the database as JSON
class AddQuizWidget extends StatefulWidget {
  const AddQuizWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddQuizWidgetState createState() => _AddQuizWidgetState();
}

class _AddQuizWidgetState extends State<AddQuizWidget> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addQuizToFirebase() async {
    try {
      // Parse the JSON data and add the quiz to Firebase
      final jsonData = json.decode(_jsonController.text);
      await _firestore
          .collection('quizzes')
          .doc('Pilot Program')
          .collection('beginner')
          .doc(_titleController.text)
          .set(jsonData);
      showTextSnackBar('Quiz added successfully!');

      _jsonController.clear();
      _titleController.clear();
    } catch (e) {
      showTextSnackBar('Error adding quiz: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: FloatingBox(
        child: Column(
          children: [
            // The title of the document
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                controller: _titleController,
                decoration: denseInputDecor('Title of document'),
              ),
            ),
            // The data of the document
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextFormField(
                controller: _jsonController,
                maxLines: 10,
                decoration: denseInputDecor('Paste your JSON data here...'),
              ),
            ),
            ElevatedButton(
              onPressed: _addQuizToFirebase,
              child: const Text('Add Quiz to Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}

// This is the input decoration used for text fields on the profile page
InputDecoration denseInputDecor(String hintText) {
  return InputDecoration(
    hintText: hintText,
    isDense: true,
    contentPadding: const EdgeInsets.only(bottom: 5, top: 3),
  );
}
