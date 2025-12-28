import 'package:flutter/material.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';

import '../../../scaffolds/app_bar_scaffold.dart';
import 'widgets/profile_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarScaffold(
      title: context.l10n.myProfile,
      actions: [
        Badge.count(
          offset: const Offset(-5, 5),
          count: 0,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ),
      ],
      child: ProfileWidget(),
    );
  }
}
