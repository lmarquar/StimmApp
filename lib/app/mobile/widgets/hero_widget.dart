import 'package:flutter/material.dart';
import 'package:stimmapp/core/data/services/auth_service.dart';

class HeroWidget extends StatelessWidget {
  const HeroWidget({super.key, this.title, this.nextPage});

  final String? title;
  final Widget? nextPage;

  @override
  Widget build(BuildContext context) {
    final currentUrl = authService.currentUser?.photoURL;
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              // Ensure the widget's height never exceeds its width
              maxHeight: constraints.maxWidth,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: 'hero1',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: (currentUrl != null && currentUrl.isNotEmpty)
                          ? Image.network(
                              currentUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.asset(
                              'assets/images/default_avatar.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                  ),
                  Text(
                    title != null ? title! : '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                      letterSpacing: 50,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
