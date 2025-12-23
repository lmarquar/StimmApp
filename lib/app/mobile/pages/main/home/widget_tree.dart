import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/home/home_navigation_config.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/profile_page.dart';
import 'package:stimmapp/core/services/auth_service.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/app/mobile/pages/main/settings/settings_page.dart';
import 'package:stimmapp/app/mobile/widgets/navbar_widget.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUrl = authService.value.currentUser?.photoURL;

    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        final pages = mainPagesConfig(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(pages[selectedPage].title),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                icon: currentUrl != null
                    ? CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(currentUrl),
                        backgroundColor: Colors.transparent,
                      )
                    : const CircleAvatar(
                        radius: 18,
                        child: Icon(Icons.person, size: 18),
                      ),
                tooltip: context.l10n.myProfile,
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
