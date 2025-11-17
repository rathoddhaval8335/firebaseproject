import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authservice.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              // AuthWrapper will send user to LoginScreen
            },
            tooltip: 'Sign out',
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome, ${user?.email ?? 'User'}'),
            SizedBox(height: 8),
            Text('UID: ${user?.uid ?? 'N/A'}'),
            SizedBox(height: 8),
            if (user != null && !user.emailVerified)
              Column(
                children: [
                  Text('Email not verified', style: TextStyle(color: Colors.orange)),
                  ElevatedButton(
                    onPressed: () async {
                      await user.sendEmailVerification();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification email sent.')));
                    },
                    child: Text('Resend verification email'),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
