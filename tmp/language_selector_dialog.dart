import 'package:flutter/material.dart';
import 'package:stimmapp/core/extensions/context_extensions.dart';
import 'package:stimmapp/core/notifiers/notifiers.dart';
import 'package:stimmapp/l10n/app_localizations.dart';

class LanguageSelectorDialog extends StatefulWidget {
  const LanguageSelectorDialog({super.key});

  @override
  State<LanguageSelectorDialog> createState() => _LanguageSelectorDialogState();
}

class _LanguageSelectorDialogState extends State<LanguageSelectorDialog> {
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale =
        appLocale.value ?? AppLocalizations.supportedLocales.first;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Language',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: AppLocalizations.supportedLocales.map((locale) {
                  return RadioListTile<Locale>(
                    title: Text(_getLanguageName(appLocalizations, locale)),
                    value: locale,
                    groupValue: _selectedLocale,
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          _selectedLocale = value;
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(appLocalizations.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    appLocale.value = _selectedLocale;
                    Navigator.of(context).pop();
                  },
                  child: Text(context.l10n.confirm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(AppLocalizations appLocalizations, Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'de':
        return 'German';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}
