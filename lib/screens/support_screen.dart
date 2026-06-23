import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carby/theme/app_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('🦀', style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(
                'Carby ist kostenlos.\nDas hat einen Preis. 🙂',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Ich entwickle Carby alleine, in meiner Freizeit. Google Play kostet Geld, iOS-Veröffentlichung 99\$ pro Jahr — und Updates schreiben sich nicht von selbst.\n\nWenn dir die App gefällt und du mich unterstützen möchtest, freue ich mich über jede Spende. Muss nicht sein. Aber tut gut.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          final uri =
                              Uri.parse('https://paypal.me/FredericSchroer');
                          if (await canLaunchUrl(uri)) {
                            launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
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
                    Text(
                      'Öffnet PayPal in deinem Browser.\nKein Konto nötig.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(color: Color(0xFF2A2A2A)),
                    const SizedBox(height: 20),
                    Text(
                      'Bug melden oder Feedback geben:',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.parse('mailto:ArcadiaApps@proton.me?subject=Carby%20Feedback');
                        if (await canLaunchUrl(uri)) launchUrl(uri);
                      },
                      child: Text(
                        'ArcadiaApps@proton.me',
                        style: GoogleFonts.inter(
                          color: AppColors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
