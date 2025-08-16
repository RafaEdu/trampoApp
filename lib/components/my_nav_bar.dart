import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyNavBar extends StatelessWidget {
  final int selectedIndex;

  const MyNavBar({super.key, required this.selectedIndex});

  void navigateTo(int index, BuildContext context) {
    if (index == selectedIndex) return; // Se já está na página, não faz nada

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/perfil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
        child: GNav(
          backgroundColor: Colors.grey.shade200,
          color: Colors.black,
          activeColor: Colors.black,
          tabBackgroundColor: Colors.grey.shade400,
          gap: 7,
          padding: const EdgeInsets.all(18),
          selectedIndex: selectedIndex,
          onTabChange: (index) => navigateTo(index, context),
          tabs: const [
            GButton(icon: Icons.home, text: 'HOME'),
            GButton(icon: Icons.person, text: 'PERFIL'),
          ],
        ),
      ),
    );
  }
}
