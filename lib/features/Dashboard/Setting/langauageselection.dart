import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_project/providers/locale_provider.dart';
import 'package:school_project/l10n/app_localizations.dart';

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final localizer = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizer.selectLanguage)),
      body: ListView(
        children: [
          _buildTile(context, ref, 'en', localizer.english),
          _buildTile(context, ref, 'fr', localizer.french),
          _buildTile(context, ref, 'rw', localizer.kinyarwanda),
        ],
      ),
    );
  }

  ListTile _buildTile(BuildContext context, WidgetRef ref, String code, String title) {
    return ListTile(
      title: Text(title),
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(Locale(code));
        Navigator.pop(context);
      },
    );
  }
}
