import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/home/creator/petition_creator_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/creator/poll_creator_page.dart';

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
              child: const Text("Petition entwerfen"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PollCreatorPage(),
                  ),
                );
              },
              child: const Text("Umfrage entwerfen"),
            ),
            const Divider(color: Colors.teal, thickness: 5),
          ],
        ),
      ),
    );
  }
}
