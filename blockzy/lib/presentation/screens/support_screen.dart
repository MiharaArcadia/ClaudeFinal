/// Support page — the required message, verbatim, plus a Donate button that
/// opens the developer's PayPal.me link.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design_tokens.dart';
import '../widgets/common.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // The developer's PayPal.me link (reused from prior projects).
  static final Uri _payPal = Uri.parse('https://paypal.me/FredericSchroer');

  /// The support message, exactly as specified in the brief.
  static const String _message = '''
No advertisements.

This game costs only €0.99.

My dream is to eventually release it on iOS.

If you enjoy the game and would like to support my journey toward becoming a successful independent app developer, you are welcome to donate.

Every contribution helps.

Thank you for being part of this adventure.''';

  Future<void> _donate(BuildContext context) async {
    try {
      final ok = await launchUrl(_payPal, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PayPal.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open PayPal.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Support',
      child: ListView(
        children: [
          const SizedBox(height: BlockzySpacing.md),
          const Icon(Icons.favorite_rounded,
              color: BlockzyColors.accentPink, size: 56),
          const SizedBox(height: BlockzySpacing.md),
          Panel(
            child: Text(
              _message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: BlockzyColors.textPrimary,
                  ),
            ),
          ),
          const SizedBox(height: BlockzySpacing.xl),
          GradientButton(
            label: 'Donate via PayPal',
            icon: Icons.volunteer_activism_rounded,
            gradient: BlockzyGradients.candyPink,
            onTap: () => _donate(context),
          ),
          const SizedBox(height: BlockzySpacing.md),
          Center(
            child: Text(
              'No ads · No subscriptions · No pay-to-win',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
