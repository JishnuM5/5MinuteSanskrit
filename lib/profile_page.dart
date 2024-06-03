import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'themes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Profile", style: Theme.of(context).textTheme.displayLarge),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [shadow],
                ),
                child: Column(
                  children: [
                    Text(
                      "Signed in as",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    FutureBuilder(
                        future: getName(user!),
                        initialData: "",
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? "Error retrieving data",
                            style: Theme.of(context).textTheme.headlineSmall,
                          );
                        }),
                    const SizedBox(height: 20),
                    Text(
                      "Email",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      user.email!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getName(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.email);
    final userDocSnap = await userRef.get();
    return userDocSnap.data()!['name'];
  }
}
