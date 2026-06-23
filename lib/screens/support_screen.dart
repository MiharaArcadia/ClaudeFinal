import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carby/theme/app_theme.dart';

// Replace with your Discord webhook URL after creating it in Discord
const _discordWebhook = 'https://discord.com/api/webhooks/1519057810275438784/_5KMfihPPBbIljR7XvteDHCBqCwqdfKwtVUsMD5K9zU_37IukLgdnVDut_RDPPs0FpIm';

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
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _showFeedbackSheet(context),
                        icon: const Icon(Icons.bug_report_outlined,
                            color: Color(0xFFFFC107), size: 18),
                        label: Text(
                          '🐛  Problem melden / Feedback',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFFFC107),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFFFC107), width: 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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

void _showFeedbackSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1A1A1A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _FeedbackSheet(),
  );
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet();
  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _ctrl = TextEditingController();
  XFile? _image;
  bool _sending = false;
  bool _sent = false;

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Galerie-Zugriff nicht erlaubt.'),
          action: SnackBarAction(
              label: 'Einstellungen',
              onPressed: openAppSettings),
        ));
      }
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _image = picked);
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);

    try {
      if (_discordWebhook == 'YOUR_DISCORD_WEBHOOK_URL') {
        // Fallback: open mailto if webhook not configured
        final uri = Uri.parse(
            'mailto:ArcadiaApps@proton.me?subject=Carby%20Feedback&body=${Uri.encodeComponent(text)}');
        if (await canLaunchUrl(uri)) await launchUrl(uri);
        if (mounted) Navigator.pop(context);
        return;
      }

      final payload = jsonEncode({
        'embeds': [
          {
            'title': '🐛 Carby Feedback',
            'description': text,
            'color': 16737843,
            'fields': [
              {'name': 'Platform', 'value': Platform.operatingSystem, 'inline': true},
              {'name': 'Version', 'value': '1.0.0', 'inline': true},
            ],
            'footer': {'text': 'Carby In-App Feedback'},
          }
        ],
      });

      if (_image != null) {
        final req = http.MultipartRequest('POST', Uri.parse(_discordWebhook));
        req.fields['payload_json'] = payload;
        req.files.add(await http.MultipartFile.fromPath(
          'file', _image!.path,
          filename: 'screenshot.jpg',
        ));
        await req.send();
      } else {
        await http.post(
          Uri.parse(_discordWebhook),
          headers: {'Content-Type': 'application/json'},
          body: payload,
        );
      }
      setState(() => _sent = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Feedback konnte nicht gesendet werden.'),
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Problem melden',
              style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Dein Feedback hilft Carby besser zu machen.',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            maxLines: 5,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Was ist passiert?',
              hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(_image!.path),
                  height: 80, fit: BoxFit.cover),
            ),
          Row(
            children: [
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined,
                    color: AppColors.textSecondary, size: 16),
                label: Text(
                  _image == null ? 'Screenshot anhängen' : 'Bild ändern',
                  style: GoogleFonts.inter(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              const Spacer(),
              if (_sent)
                Row(children: [
                  const Icon(Icons.check_circle,
                      color: Colors.greenAccent, size: 18),
                  const SizedBox(width: 6),
                  Text('Gesendet!',
                      style: GoogleFonts.inter(
                          color: Colors.greenAccent, fontSize: 13)),
                ])
              else
                ElevatedButton(
                  onPressed: _sending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text('Absenden',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
