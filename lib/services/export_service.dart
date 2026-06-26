import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:clocky/models/entry.dart';
import 'package:clocky/models/project.dart';

class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  // ── PDF ──────────────────────────────────────────────────────────────────────

  Future<Uint8List> generatePdf(
    List<Entry> entries,
    List<Project> projects,
    Map<String, String> settings,
    String month, // 'YYYY-MM'
  ) async {
    final pdf = pw.Document();

    // Build project lookup
    final projectMap = {for (final p in projects) p.id: p};

    // Parse month for display
    final monthDate = DateFormat('yyyy-MM').parse(month);
    final monthLabel = DateFormat('MMMM yyyy', 'de_DE').format(monthDate);

    // Freelancer info from settings
    final freelancerName = settings['name'] ?? '';
    final company = settings['company'] ?? '';
    final address = settings['address'] ?? '';

    // Sort entries by date
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

    // Totals
    final totalHours = sorted.fold(0.0, (s, e) => s + e.totalHours);
    final totalEarnings = sorted.fold(0.0, (s, e) {
      final project = projectMap[e.projectId];
      return s + e.totalHours * (project?.hourlyRate ?? 0);
    });

    final orange = PdfColor.fromHex('FF6B35');
    final darkBg = PdfColor.fromHex('121212');
    final grey = PdfColor.fromHex('666666');
    final lightGrey = PdfColor.fromHex('F5F5F5');

    final headerStyle = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final subHeaderStyle = pw.TextStyle(
      fontSize: 10,
      color: PdfColor.fromHex('444444'),
    );
    final tableHeaderStyle = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );
    final cellStyle = pw.TextStyle(fontSize: 9, color: PdfColors.black);
    final totalStyle = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Stundenzettel', style: headerStyle),
                    pw.SizedBox(height: 4),
                    pw.Text(monthLabel, style: pw.TextStyle(fontSize: 14, color: orange, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (freelancerName.isNotEmpty)
                      pw.Text(freelancerName, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    if (company.isNotEmpty)
                      pw.Text(company, style: subHeaderStyle),
                    if (address.isNotEmpty)
                      pw.Text(address, style: subHeaderStyle),
                  ],
                ),
              ],
            ),

            pw.Divider(color: orange, thickness: 2),
            pw.SizedBox(height: 16),

            // Table
            pw.Table(
              border: pw.TableBorder(
                horizontalInside: pw.BorderSide(color: PdfColor.fromHex('E0E0E0'), width: 0.5),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.8), // Datum
                1: const pw.FlexColumnWidth(2.2), // Projekt
                2: const pw.FlexColumnWidth(1.2), // Beginn
                3: const pw.FlexColumnWidth(1.2), // Ende
                4: const pw.FlexColumnWidth(1.0), // Pause
                5: const pw.FlexColumnWidth(1.0), // Gesamt
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: orange),
                  children: [
                    _tableCell('Datum', tableHeaderStyle),
                    _tableCell('Projekt', tableHeaderStyle),
                    _tableCell('Beginn', tableHeaderStyle),
                    _tableCell('Ende', tableHeaderStyle),
                    _tableCell('Pause', tableHeaderStyle),
                    _tableCell('Gesamt', tableHeaderStyle),
                  ],
                ),
                // Data rows
                ...sorted.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final project = projectMap[e.projectId];
                  final bg = i.isEven ? PdfColors.white : PdfColor.fromHex('FAFAFA');
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: bg),
                    children: [
                      _tableCell(_formatDateDe(e.date), cellStyle),
                      _tableCell(project?.name ?? '–', cellStyle),
                      _tableCell(e.startTime, cellStyle),
                      _tableCell(e.endTime, cellStyle),
                      _tableCell('${e.pauseMinutes} min', cellStyle),
                      _tableCell(e.formattedDuration, cellStyle),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 16),

            // Totals box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightGrey,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Gesamtstunden:', style: totalStyle),
                  pw.Text(_formatHours(totalHours), style: totalStyle),
                  pw.SizedBox(width: 32),
                  pw.Text('Gesamtbetrag:', style: totalStyle),
                  pw.Text(
                    NumberFormat.currency(locale: 'de_DE', symbol: '€').format(totalEarnings),
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: orange),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 40),

            // Signature
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 200, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    pw.Text('Datum, Unterschrift Auftraggeber', style: pw.TextStyle(fontSize: 8, color: grey)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(width: 200, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    pw.Text('Datum, Unterschrift Auftragnehmer', style: pw.TextStyle(fontSize: 8, color: grey)),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColor.fromHex('E0E0E0')),
            pw.SizedBox(height: 4),
            pw.Text(
              'Erstellt mit Clocky · ${DateFormat('dd.MM.yyyy', 'de_DE').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 7, color: grey),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _tableCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(text, style: style),
    );
  }

  String _formatDateDe(String dateStr) {
    try {
      final dt = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('dd.MM.yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (m == 0) return '${h}h';
    return '${h}h ${m.toString().padLeft(2, '0')}m';
  }

  // ── CSV ──────────────────────────────────────────────────────────────────────

  Future<String> generateCsv(List<Entry> entries, List<Project> projects) async {
    final projectMap = {for (final p in projects) p.id: p};
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

    final buffer = StringBuffer();
    buffer.writeln('Datum;Projekt;Kunde;Beginn;Ende;Pause(min);Stunden;Betrag(EUR)');

    for (final e in sorted) {
      final project = projectMap[e.projectId];
      final projectName = _csvEscape(project?.name ?? '');
      final clientName = _csvEscape(project?.clientName ?? '');
      final hours = e.totalHours;
      final rate = project?.hourlyRate ?? 0.0;
      final earnings = hours * rate;

      buffer.writeln(
        '${_formatDateDe(e.date)};'
        '$projectName;'
        '$clientName;'
        '${e.startTime};'
        '${e.endTime};'
        '${e.pauseMinutes};'
        '${hours.toStringAsFixed(2)};'
        '${earnings.toStringAsFixed(2)}',
      );
    }

    return buffer.toString();
  }

  String _csvEscape(String value) {
    if (value.contains(';') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  // ── Share ─────────────────────────────────────────────────────────────────────

  Future<void> shareFile(
    Uint8List bytes,
    String filename,
    String mimeType,
  ) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(bytes);

    final xFile = XFile(file.path, mimeType: mimeType, name: filename);
    await Share.shareXFiles([xFile], subject: filename);
  }

  // ── Email ─────────────────────────────────────────────────────────────────────

  Future<void> sendEmail(
    String? to,
    String subject,
    String body,
    Uint8List? attachment,
    String? attachmentName,
  ) async {
    if (attachment != null && attachmentName != null) {
      // Save attachment and share instead (mailto doesn't support attachments reliably)
      final mimeType = attachmentName.endsWith('.pdf')
          ? 'application/pdf'
          : 'text/csv';
      await shareFile(attachment, attachmentName, mimeType);
      return;
    }

    final encodedSubject = Uri.encodeComponent(subject);
    final encodedBody = Uri.encodeComponent(body);
    final toParam = to != null && to.isNotEmpty ? to : '';
    final mailtoUri = Uri.parse('mailto:$toParam?subject=$encodedSubject&body=$encodedBody');

    if (await canLaunchUrl(mailtoUri)) {
      await launchUrl(mailtoUri);
    }
  }
}
