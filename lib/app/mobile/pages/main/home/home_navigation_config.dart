import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/home/creator/creator_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/petitions/petitions_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/polls/polls_page.dart';

/// A simple class to hold the configuration for a main page in the app.
class MainPageConfig {
  final Widget page;
  final String title;
  final IconData icon;

  const MainPageConfig({
    required this.page,
    required this.title,
    required this.icon,
  });
}

/// The single source of truth for the main pages in the navigation bar.
const List<MainPageConfig> mainPagesConfig = [
  MainPageConfig(
    page: PetitionsPage(),
    title: 'Petitionen',
    icon: Icons.drive_file_rename_outline,
  ),
  MainPageConfig(page: CreatorPage(), title: 'Gestalter', icon: Icons.mail),
  MainPageConfig(page: PollsPage(), title: 'Umfragen', icon: Icons.ballot),
];
