/// Settings — audio, haptics, performance, battery saver, and accessibility.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/design_tokens.dart';
import '../player_controller.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final s = player.settings;
    return ScreenScaffold(
      title: 'Settings',
      child: ListView(
        children: [
          Panel(
            child: Column(
              children: [
                _slider(
                  context,
                  label: 'Music volume',
                  icon: Icons.music_note_rounded,
                  value: s.musicVolume,
                  onChanged: (v) =>
                      player.updateSettings((s) => s.musicVolume = v),
                ),
                _slider(
                  context,
                  label: 'Sound volume',
                  icon: Icons.volume_up_rounded,
                  value: s.soundVolume,
                  onChanged: (v) =>
                      player.updateSettings((s) => s.soundVolume = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: BlockzySpacing.md),
          Panel(
            child: Column(
              children: [
                _toggle(
                  context,
                  label: 'Haptic feedback',
                  value: s.hapticsEnabled,
                  onChanged: (v) =>
                      player.updateSettings((s) => s.hapticsEnabled = v),
                ),
                _toggle(
                  context,
                  label: 'High performance mode',
                  subtitle: 'Maximise animation smoothness (60 FPS)',
                  value: s.highPerformanceMode,
                  onChanged: (v) =>
                      player.updateSettings((s) => s.highPerformanceMode = v),
                ),
                _toggle(
                  context,
                  label: 'Battery saver',
                  subtitle: 'Lighter visuals, fewer particles',
                  value: s.batterySaver,
                  onChanged: (v) =>
                      player.updateSettings((s) => s.batterySaver = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: BlockzySpacing.md),
          Text('Accessibility',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: BlockzySpacing.sm),
          Panel(
            child: Column(
              children: [
                _toggle(
                  context,
                  label: 'Colour-blind candy shapes',
                  subtitle: 'Distinct shapes as well as colours',
                  value: s.colorBlindShapes,
                  onChanged: (v) =>
                      player.updateSettings((s) => s.colorBlindShapes = v),
                ),
                _toggle(
                  context,
                  label: 'Reduced motion',
                  subtitle: 'Calmer animations and screen shake',
                  value: s.reducedMotion,
                  onChanged: (v) =>
                      player.updateSettings((s) => s.reducedMotion = v),
                ),
                _toggle(
                  context,
                  label: 'Large text',
                  value: s.largeText,
                  onChanged: (v) =>
                      player.updateSettings((s) => s.largeText = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    BuildContext context, {
    required String label,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: BlockzyColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(width: 110, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            onChanged: onChanged,
            activeColor: BlockzyColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _toggle(
    BuildContext context, {
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle),
      value: value,
      activeColor: BlockzyColors.primary,
      onChanged: onChanged,
    );
  }
}
