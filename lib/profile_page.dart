import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanskrit_web_app/my_app_state.dart';
import 'themes.dart';

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
    _nameController = TextEditingController(
      text: context.watch<MyAppState>().appUser.name,
    );
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Profile', style: Theme.of(context).textTheme.displayLarge),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Divider(),
            ),
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
                    ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        context.read<MyAppState>().navigateTo(0);
                      },
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FloatingBox(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
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
                            onPressed: () async {
                              Future.wait([
                                deleteUserData(),
                                FirebaseAuth.instance.currentUser!.delete(),
                              ])
                                  .then(
                                    (value) => (
                                      showTextSnackBar("User account deleted"),
                                    ),
                                  )
                                  .catchError(
                                    (error) => (
                                      showTextSnackBar(
                                          "Error deleting user: $error"),
                                    ),
                                  );
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

  InputDecoration denseInputDecor(String hintText) {
    return InputDecoration(
      hintText: hintText,
      isDense: true,
      contentPadding: const EdgeInsets.only(bottom: 5, top: 3),
    );
  }

  Future deleteUserData() async {
    try {
      String email = FirebaseAuth.instance.currentUser!.email!;
      final userRef = FirebaseFirestore.instance.collection('users').doc(email);
      await userRef.delete();
    } catch (error) {
      return Future.error('$error');
    }
  }
}
