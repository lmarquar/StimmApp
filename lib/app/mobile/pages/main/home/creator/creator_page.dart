import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/home/creator/petition_creator_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/creator/poll_creator_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/home_navigation_config.dart';
import 'package:stimmapp/app/mobile/widgets/blurrable_button_widget.dart';

class CreatorPage extends StatefulWidget {
  const CreatorPage({super.key});

  @override
  State<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const Divider(thickness: 5),
            BlurrableButton(
              icon: mainPagesConfig(context)[0].icon,
              title: mainPagesConfig(context)[0].title,
              description: 'erstelle eine neue Petition',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PetitionCreatorPage(),
                  ),
                );
              },
              isBlurred: false,
            ),
            const Divider(thickness: 5),
            BlurrableButton(
              icon: mainPagesConfig(context)[2].icon,
              title: mainPagesConfig(context)[2].title,
              description: 'erstelle eine neue Umfrage',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PollCreatorPage(),
                  ),
                );
              },
              isBlurred: false,
            ),
          ],
        ),
      ),
    );
  }
}
