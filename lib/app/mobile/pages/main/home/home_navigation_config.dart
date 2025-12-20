import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/home/creator/creator_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/petitions/petitions_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/polls/polls_page.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

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
/// Call `mainPagesConfig(context)` to obtain localized titles.
List<MainPageConfig> mainPagesConfig(BuildContext context) => [
  MainPageConfig(
    page: const PetitionsPage(),
    title: context.l10n.petition,
    icon: Icons.drive_file_rename_outline,
  ),
  MainPageConfig(
    page: const CreatorPage(),
    title: context.l10n.creator,
    icon: Icons.mail,
  ),
  MainPageConfig(
    page: const PollsPage(),
    title: context.l10n.polls,
    icon: Icons.ballot,
  ),
];
