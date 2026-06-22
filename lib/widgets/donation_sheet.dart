import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carby/theme/app_theme.dart';

const _nextTriggerKey = 'donation_next_trigger';
const _totalEntriesKey = 'total_entries';

Future<void> maybeShowDonationSheet(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final count = prefs.getInt(_totalEntriesKey) ?? 0;
  final nextTrigger = prefs.getInt(_nextTriggerKey) ?? 5;
  if (count < nextTrigger) return;
  if (!context.mounted) return;
  // Set sentinel so popup won't fire again until user picks a donation amount
  await prefs.setInt(_nextTriggerKey, 999999);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _DonationSheet(),
  );
}

class _DonationSheet extends StatelessWidget {
  const _DonationSheet();

  Future<void> _openPayPal(BuildContext context) async {
    final uri = Uri.parse('https://paypal.me/FredericSchroer');
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!context.mounted) return;
    // Silent thank-you dialog — no mention of next trigger timing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '❤️ Vielen Dank!',
          style: GoogleFonts.inter(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Wie viel hast du gespendet?',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          _AmountButton(label: '1 €', dialogCtx: dialogCtx, sheetCtx: context, offset: 50),
          _AmountButton(label: '3 €', dialogCtx: dialogCtx, sheetCtx: context, offset: 150),
          _AmountButton(label: '5 €', dialogCtx: dialogCtx, sheetCtx: context, offset: 1000),
        ],
      ),
    );
  }

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
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text('🦀', style: TextStyle(fontSize: 48)),
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
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _openPayPal(context),
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

class _AmountButton extends StatelessWidget {
  final String label;
  final BuildContext dialogCtx;
  final BuildContext sheetCtx;
  final int offset;

  const _AmountButton({
    required this.label,
    required this.dialogCtx,
    required this.sheetCtx,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        final count = prefs.getInt(_totalEntriesKey) ?? 0;
        await prefs.setInt(_nextTriggerKey, count + offset);
        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
        if (sheetCtx.mounted) Navigator.pop(sheetCtx);
      },
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: AppColors.orange,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
