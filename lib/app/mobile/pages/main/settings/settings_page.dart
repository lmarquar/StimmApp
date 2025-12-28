import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stimmapp/app/mobile/pages/main/profile/profile_page.dart';
import 'package:stimmapp/app/mobile/widgets/unaffected_child_widget.dart';
import 'package:stimmapp/core/constants/constants.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/core/theme/app_text_styles.dart';
import 'package:stimmapp/l10n/app_localizations.dart';
import 'package:stimmapp/app/mobile/widgets/selection_notifier_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.title});

  final String title;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void popUntilLast() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  TextEditingController controller = TextEditingController();
  bool isChecked = false;
  bool isSwitched = false;
  double sliderValue = 0.0;
  String? menuItem = 'e1';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              UnaffectedChildWidget(
                child: Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    trailing: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.white38,
                    ),
                    title: Text(context.l10n.myProfile),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProfilePage();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              UnaffectedChildWidget(
                child: ListTile(
                  title: Text(context.l10n.colorTheme),
                  onTap: () async {
                    isDarkModeNotifier.value = !isDarkModeNotifier.value;
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.setBool('isDarkMode', isDarkModeNotifier.value);
                  },
                  trailing: ValueListenableBuilder(
                    valueListenable: isDarkModeNotifier,
                    builder: (context, isDarkMode, child) {
                      return Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      );
                    },
                  ),
                ),
              ),
              UnaffectedChildWidget(
                child: ListTile(
                  title: Text(context.l10n.changeLanguage),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SelectionNotifierDialog<Locale>(
                        notifier: appLocale,
                        options: AppLocalizations.supportedLocales,
                        optionLabel: (ctx, locale) {
                          switch (locale.languageCode) {
                            case 'en':
                              return ctx.l10n.english;
                            case 'de':
                              return ctx.l10n.german;
                            default:
                              return locale.languageCode.toUpperCase();
                          }
                        },
                        title: context.l10n.language,
                        confirmLabel: context.l10n.confirm,
                        cancelLabel: context.l10n.cancel,
                        onConfirm: (Locale? selected) async {
                          final prefs = await SharedPreferences.getInstance();
                          String toSave = '';
                          if (selected != null) {
                            toSave =
                                selected.countryCode == null ||
                                    selected.countryCode!.isEmpty
                                ? selected.languageCode
                                : '${selected.languageCode}_${selected.countryCode}';
                          }
                          await prefs.setString(KConst.localeKey, toSave);
                        },
                      ),
                    );
                  },
                ),
              ),
              UnaffectedChildWidget(
                child: ListTile(
                  title: Text(context.l10n.aboutThisApp),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(context.l10n.aboutThisApp),
                          content: Text(
                            context.l10n.stimmapp,
                            style: AppTextStyles.m,
                          ),
                          actions: [
                            FilledButton(
                              onPressed: () async {
                                showLicensePage(context: context);
                              },
                              child: Text(context.l10n.viewLicenses),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(context.l10n.close),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),

              Divider(color: Colors.teal, thickness: 5),
            ],
          ),
        ),
      ),
    );
  }
}
