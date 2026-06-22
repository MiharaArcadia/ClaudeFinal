import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carby/theme/app_theme.dart';

const _shownKey = 'donation_sheet_shown';

Future<void> maybeShowDonationSheet(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_shownKey) == true) return;
  if (!context.mounted) return;
  await prefs.setBool(_shownKey, true);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _DonationSheet(),
  );
}

class _DonationSheet extends StatelessWidget {
  const _DonationSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Crab + title
          Text('🦀', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Carby ist kostenlos.\nDas hat einen Preis. 🙂',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Body text
          Text(
            'Ich entwickle Carby alleine, in meiner Freizeit. Google Play kostet Geld, iOS-Veröffentlichung 99\$ pro Jahr — und Updates schreiben sich nicht von selbst.\n\nWenn dir die App gefällt und du mich unterstützen möchtest, freue ich mich über jede Spende. Muss nicht sein. Aber tut gut.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),

          // Donate button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                final uri = Uri.parse('https://paypal.me/FredericSchroer');
                if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0070BA),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                '❤️  Via PayPal spenden',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dismiss
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Vielleicht später',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
