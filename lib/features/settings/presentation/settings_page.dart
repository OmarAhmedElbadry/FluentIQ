import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/domain/app_types.dart';
import '../../../shared/presentation/app_components.dart';
import '../domain/user_preferences.dart';
import 'settings_cubit.dart';

/// A modern preference hub for appearance, assessment, accessibility and app information.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: BlocBuilder<SettingsCubit, UserPreferences>(
          builder: (context, preferences) => ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xxl),
            children: [
              const _SettingsHeader(),
              const SizedBox(height: AppSpacing.lg),
              _SettingsSection(
                title: 'Appearance',
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: AppColors.purple,
                    iconBackground: AppColors.purpleTintDark,
                    title: 'Theme',
                    subtitle: preferences.theme.label,
                    onTap: () => _showThemePicker(context, preferences.theme),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsSection(
                title: 'Assessment',
                children: [
                  _SettingsTile(
                    icon: Icons.translate_rounded,
                    iconColor: AppColors.brandGreen,
                    iconBackground: AppColors.greenTintDark,
                    title: 'Assessment language',
                    subtitle: preferences.assessmentLanguage.label,
                    onTap: () => _showLanguagePicker(context, preferences.assessmentLanguage),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsSection(
                title: 'Accessibility',
                children: [
                  _SettingsTile(
                    icon: Icons.format_size_rounded,
                    iconColor: AppColors.brandOrange,
                    iconBackground: AppColors.orangeTintDark,
                    title: 'Text size',
                    subtitle: _textScaleLabel(preferences.textScale),
                    onTap: () => _showTextSizePicker(context, preferences.textScale),
                  ),
                  _SettingsToggleTile(
                    icon: Icons.motion_photos_off_outlined,
                    iconColor: AppColors.brandOrange,
                    iconBackground: AppColors.orangeTintDark,
                    title: 'Reduce motion',
                    subtitle: 'Limit non-essential animations',
                    value: preferences.reduceMotion,
                    onChanged: context.read<SettingsCubit>().setReduceMotion,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SettingsSection(
                title: 'Legal & app',
                children: [
                  _SettingsTile(
                    icon: Icons.verified_user_outlined,
                    iconColor: AppColors.brandGreen,
                    iconBackground: AppColors.greenTintDark,
                    title: 'Privacy policy',
                    subtitle: 'How LinguaIQ handles your data',
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.purple,
                    iconBackground: AppColors.purpleTintDark,
                    title: 'About LinguaIQ',
                    subtitle: 'AI-powered language assessment',
                    onTap: () => _showAbout(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  void _showThemePicker(BuildContext context, AppThemePreference current) => _showPicker<AppThemePreference>(
        context: context,
        title: 'Choose theme',
        current: current,
        values: AppThemePreference.values,
        label: (value) => value.label,
        onSelected: context.read<SettingsCubit>().setTheme,
      );

  void _showLanguagePicker(BuildContext context, AppLanguage current) => _showPicker<AppLanguage>(
        context: context,
        title: 'Assessment language',
        current: current,
        values: AppLanguage.values,
        label: (value) => value.label,
        onSelected: context.read<SettingsCubit>().setLanguage,
      );

  void _showTextSizePicker(BuildContext context, double current) => _showPicker<double>(
        context: context,
        title: 'Text size',
        current: current,
        values: const [0.9, 1, 1.15],
        label: _textScaleLabel,
        onSelected: context.read<SettingsCubit>().setTextScale,
      );

  void _showPicker<T>({
    required BuildContext context,
    required String title,
    required T current,
    required List<T> values,
    required String Function(T value) label,
    required ValueChanged<T> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              ...values.map(
                (value) => RadioListTile<T>(
                  value: value,
                  groupValue: current,
                  title: Text(label(value)),
                  onChanged: (selected) {
                    if (selected == null) return;
                    onSelected(selected);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) => _showInfoSheet(
        context,
        title: 'Privacy policy',
        body:
            'LinguaIQ stores your preferences and assessment history on this device. AI-generated questions are requested only while you run an assessment. Do not enter sensitive personal information in free-response answers.',
      );

  void _showAbout(BuildContext context) => _showInfoSheet(
        context,
        title: 'About LinguaIQ',
        body:
            'LinguaIQ is an AI-powered language assessment product. It estimates CEFR proficiency through adaptive questions and clear skill feedback.',
      );

  void _showInfoSheet(BuildContext context, {required String title, required String body}) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Text(body, style: Theme.of(sheetContext).textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => Navigator.pop(sheetContext), child: const Text('Done')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _textScaleLabel(double value) => switch (value) {
        < 1 => 'Small',
        > 1 => 'Large',
        _ => 'Default',
      };
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSpacing.xs),
          Text('Personalize your LinguaIQ experience.', style: Theme.of(context).textTheme.bodyLarge),
        ],
      );
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
            child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelMedium),
          ),
          AppCard(
            child: Column(
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  children[index],
                  if (index < children.length - 1) const Divider(height: AppSpacing.lg),
                ],
              ],
            ),
          ),
        ],
      );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.iconColor, required this.iconBackground, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              _SettingsIcon(icon: icon, color: iconColor, background: iconBackground),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _SettingsCopy(title: title, subtitle: subtitle)),
              Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .55)),
            ],
          ),
        ),
      );
}

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({required this.icon, required this.iconColor, required this.iconBackground, required this.title, required this.subtitle, required this.value, required this.onChanged});
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            _SettingsIcon(icon: icon, color: iconColor, background: iconBackground),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _SettingsCopy(title: title, subtitle: subtitle)),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      );
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon, required this.color, required this.background});
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Icon(icon, color: color),
      );
}

class _SettingsCopy extends StatelessWidget {
  const _SettingsCopy({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      );
}
