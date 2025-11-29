import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/ui/bars/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      //asdf
      body: Container(
        alignment: Alignment.center,
        child: const Text('Profile Screen'),
      ),
      bottomNavigationBar: BottomNavBar(
        currentRoute: ProfileScreen.routeName,
      ),
    );
  }
}
