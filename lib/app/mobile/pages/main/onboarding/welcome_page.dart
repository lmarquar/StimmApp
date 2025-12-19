import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/onboarding/login_page.dart';
import 'package:stimmapp/app/mobile/pages/main/onboarding/onboarding_page.dart';
import 'package:stimmapp/app/mobile/scaffolds/app_bottom_bar_buttons.dart';
import 'package:stimmapp/app/mobile/widgets/button_widget.dart';
import 'package:stimmapp/core/constants/app_assets.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';
import 'package:lottie/lottie.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBottomBarButtons(
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary,
                      BlendMode.srcATop,
                    ),
                    child: Lottie.asset(
                      AppAssets.lottieGrafico,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: context.l10n.welcomeTo,
                                style: AppTextStyles.xxlRed,
                              ),
                              TextSpan(
                                text: context.l10n.stimmapp,
                                style: AppTextStyles.xxlRed,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.theWelcomePhrase,
                        style: AppTextStyles.m.copyWith(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      buttons: [
        ButtonWidget(
          label: context.l10n.getStarted,
          isFilled: true,
          callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const OnboardingPage();
                },
              ),
            );
          },
        ),
        const SizedBox(height: 10.0),
        ButtonWidget(
          label: context.l10n.login,
          callback: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const LoginPage();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
