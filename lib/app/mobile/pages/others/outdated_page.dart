import 'package:flutter/material.dart';
import 'package:stimmapp/core/errors/error_message.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';
import '../../scaffolds/app_bar_scaffold.dart';
import '../../scaffolds/app_padding_scaffold.dart';
import '../../widgets/neon_padding_widget.dart';

class OutdatedPage extends StatelessWidget {
  const OutdatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBarScaffold(
        title: context.l10n.flutterPro,
        child: const AppPaddingScaffold(
          child: NeonPaddingWidget(
            child: Text(
              ErrorMessage.appVersionIsOutdated,
              style: AppTextStyles.xlBold,
            ),
          ),
        ),
      ),
    );
  }
}
