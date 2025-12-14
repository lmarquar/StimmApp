import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/widgets/hero_widget.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(height: 10),
          HeroWidget(title: 'Kerosin-Steuer'),
        ],
      ),
    );
  }
}
