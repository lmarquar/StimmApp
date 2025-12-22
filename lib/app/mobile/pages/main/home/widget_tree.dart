import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/home/home_navigation_config.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/profile_page.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/app/mobile/pages/main/settings/settings_page.dart';
import 'package:stimmapp/app/mobile/widgets/navbar_widget.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        final pages = mainPagesConfig(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(pages[selectedPage].title),
            actions: [
              IconButton(
                icon: Image.asset('assets/images/tiles.png'),
                //icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SettingsPage(title: context.l10n.settings),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: pages[selectedPage].page,
          bottomNavigationBar: const NavbarWidget(),
        );
      },
    );
  }
}
