import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/analytics/analytics_controller.dart';
import 'package:hiddify/core/localization/locale_extensions.dart';
import 'package:hiddify/core/localization/locale_preferences.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/region.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/features/config_option/notifier/config_option_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LocalePrefTile extends HookConsumerWidget {
  const LocalePrefTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final locale = ref.watch(localePreferencesProvider);

    return ListTile(
      title: Text(t.settings.general.locale),
      subtitle: Text(locale.localeName),
      leading: const Icon(FluentIcons.local_language_24_regular),
      onTap: () async {
        final selectedLocale = await showDialog<AppLocale>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text(t.settings.general.locale),
              children: AppLocale.values
                  .map(
                    (e) => RadioListTile(
                      title: Text(e.localeName),
                      value: e,
                      groupValue: locale,
                      onChanged: Navigator.of(context).maybePop,
                    ),
                  )
                  .toList(),
            );
          },
        );
        if (selectedLocale != null) {
          await ref.read(localePreferencesProvider.notifier).changeLocale(selectedLocale);
        }
      },
    );
  }
}

class RegionPrefTile extends HookConsumerWidget {
  const RegionPrefTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final region = ref.watch(ConfigOptions.region);

    return ListTile(
      title: Text(t.settings.general.region),
      subtitle: Text(region.present(t)),
      leading: const Icon(FluentIcons.globe_location_24_regular),
      onTap: () async {
        final selectedRegion = await showDialog<Region>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text(t.settings.general.region),
              children: Region.values
                  .map(
                    (e) => RadioListTile(
                      title: Text(e.present(t)),
                      value: e,
                      groupValue: region,
                      onChanged: Navigator.of(context).maybePop,
                    ),
                  )
                  .toList(),
            );
          },
        );
        if (selectedRegion != null) {
          // await ref.read(Preferences.region.notifier).update(selectedRegion);

          await ref.watch(ConfigOptions.region.notifier).update(selectedRegion);

          await ref.watch(ConfigOptions.directDnsAddress.notifier).reset();

          // await ref.read(configOptionNotifierProvider.notifier).build();
          // await ref.watch(ConfigOptions.resolveDestination.notifier).update(!ref.watch(ConfigOptions.resolveDestination.notifier).raw());
          //for reload config
          // final tmp = ref.watch(ConfigOptions.resolveDestination.notifier).raw();
          // await ref.watch(ConfigOptions.resolveDestination.notifier).update(!tmp);
          // await ref.watch(ConfigOptions.resolveDestination.notifier).update(tmp);
          //TODO: fix it
        }
      },
    );
  }
}

class EnableAnalyticsPrefTile extends HookConsumerWidget {
  const EnableAnalyticsPrefTile({
    super.key,
    this.onChanged,
  });

  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final enabled = ref.watch(analyticsControllerProvider).requireValue;

    return SwitchListTile(
      title: Text(t.settings.general.enableAnalytics),
      subtitle: Text(
        t.settings.general.enableAnalyticsMsg,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      secondary: const Icon(FluentIcons.bug_24_regular),
      value: enabled,
      onChanged: (value) async {
        if (onChanged != null) {
          return onChanged!(value);
        }
        if (enabled) {
          await ref.read(analyticsControllerProvider.notifier).disableAnalytics();
        } else {
          await ref.read(analyticsControllerProvider.notifier).enableAnalytics();
        }
      },
    );
  }
}
