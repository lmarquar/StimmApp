import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/home/creator/petition_creator_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/creator/poll_creator_page.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PetitionCreatorPage(),
                  ),
                );
              },
              child: Text(context.l10n.createPetition),
            ),
            const Divider(thickness: 5),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PollCreatorPage(),
                  ),
                );
              },
              child: Text(context.l10n.createPoll),
            ),
            const Divider(thickness: 5),
          ],
        ),
      ),
    );
  }
}
