import 'package:flutter/material.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import '../pages/main/home/home_navigation_config.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = mainPagesConfig(context);

    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: pages.map((config) {
            return NavigationDestination(
              icon: Icon(config.icon),
              label: config.title,
            );
          }).toList(),
          onDestinationSelected: (int value) {
            selectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
