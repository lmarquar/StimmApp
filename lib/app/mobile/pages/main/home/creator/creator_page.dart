import 'package:flutter/material.dart';
import 'package:stimmapp/app/mobile/pages/main/home/creator/petition_creator_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/creator/poll_creator_page.dart';
import 'package:stimmapp/app/mobile/pages/main/home/home_navigation_config.dart';
import 'package:stimmapp/app/mobile/widgets/blurrable_button_widget.dart';
import 'package:stimmapp/core/data/services/publishing_quota_service.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/app/mobile/widgets/snackbar_utils.dart';

class CreatorPage extends StatefulWidget {
  const CreatorPage({super.key});

  @override
  State<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  bool _loading = true;
  bool _canCreatePetition = false;
  bool _canCreatePoll = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await PublishingQuotaService.instance.getDailyStatus();
      if (!mounted) return;
      setState(() {
        _canCreatePetition = status.canCreatePetition;
        _canCreatePoll = status.canCreatePoll;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  void _handlePetitionPressed() {
    if (!_canCreatePetition) {
      showErrorSnackBar(context.l10n.dailyCreateLimitReached);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PetitionCreatorPage()),
    );
  }

  void _handlePollPressed() {
    if (!_canCreatePoll) {
      showErrorSnackBar(context.l10n.dailyCreateLimitReached);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PollCreatorPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const Divider(thickness: 5),
                  BlurrableButton(
                    icon: mainPagesConfig(context)[0].icon,
                    title: mainPagesConfig(context)[0].title,
                    description: context.l10n.createNewPetitionDescription,
                    onPressed: _handlePetitionPressed,
                    isBlurred: !_canCreatePetition,
                    descriptionIfBlurred:
                        context.l10n.dailyCreatePetitionLimitReached,
                  ),
                  const Divider(thickness: 5),
                  BlurrableButton(
                    icon: mainPagesConfig(context)[2].icon,
                    title: mainPagesConfig(context)[2].title,
                    description: context.l10n.createNewPollDescription,
                    onPressed: _handlePollPressed,
                    isBlurred: !_canCreatePoll,
                    descriptionIfBlurred:
                        context.l10n.dailyCreatePollLimitReached,
                  ),
                ],
              ),
      ),
    );
  }
}
