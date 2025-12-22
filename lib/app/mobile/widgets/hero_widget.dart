import 'package:flutter/material.dart';
import 'package:stimmapp/core/firebase/auth_service.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({super.key, this.title, this.nextPage});

  final String? title;
  final Widget? nextPage;

  @override
  Widget build(BuildContext context) {
    final currentUrl = authService.value.currentUser?.photoURL;
    return GestureDetector(
      onTap: nextPage != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return nextPage!;
                  },
                ),
              );
            }
          : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: 'hero1',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(currentUrl!, fit: BoxFit.cover),
            ),
          ),
          Text(
            title != null ? title! : '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 50,
              letterSpacing: 50,
              color: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}
