import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/others/outdated_page.dart';
import 'package:stimmapp/core/config/init.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import '../pages/others/app_loading_page.dart';
import 'auth_layout.dart';

class InitAppLayout extends StatefulWidget {
  const InitAppLayout({super.key});

  @override
  State<InitAppLayout> createState() => _InitAppLayoutState();
}

class _InitAppLayoutState extends State<InitAppLayout> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = initApp();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingPage();
        } else {
          return ValueListenableBuilder(
            valueListenable: AppData.isAppOutdatedNotifier,
            builder: (context, isAppOutdated, child) {
              Widget widget;
              if (isAppOutdated) {
                widget = const OutdatedPage();
              } else {
                widget = const AuthLayout();
              }
              return widget;
            },
          );
        }
      },
    );
  }
}
