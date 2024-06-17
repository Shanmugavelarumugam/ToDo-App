import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  void _logout(BuildContext context) {
    // Implement your logout logic here
    // For simplicity, let's navigate back to LoginScreen
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to your profile!',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/tasks');
              },
              child: Text('View Tasks'),
            ),
          ],
        ),
      ),
    );
  }
}
