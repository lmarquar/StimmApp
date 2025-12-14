import 'package:flutter/material.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.drive_file_rename_outline),
              label: 'Petitionen',
            ),
            NavigationDestination(icon: Icon(Icons.mail), label: 'Gestalter'),
            NavigationDestination(icon: Icon(Icons.ballot), label: 'Umfragen'),
          ],
          onDestinationSelected: (int value) {
            selectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
