import 'dart:ui';
import 'package:flutter/material.dart';

class BlurrableButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onPressed;
  final bool isBlurred;
  final double blurSigma;
  final double borderRadius;

  const BlurrableButton({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.isBlurred,
    this.blurSigma = 6.0,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );

    return Stack(
      children: [
        // Actual tappable button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: isBlurred ? null : onPressed,
            child: buttonContent,
          ),
        ),

        if (isBlurred)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  color: Colors.black.withAlpha(51),
                  alignment: Alignment.center,
                  child: const Icon(Icons.lock, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
