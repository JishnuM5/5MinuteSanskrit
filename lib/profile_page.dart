import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanskrit_web_app/my_app_state.dart';
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
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      context.read<MyAppState>().appUser.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Email',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      user!.email!,
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
            )
          ],
        ),
      ),
    );
  }
}
