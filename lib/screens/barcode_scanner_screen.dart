import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:carby/models/food_model.dart';
import 'package:carby/providers/user_provider.dart';
import 'package:carby/screens/food_detail_screen.dart';
import 'package:carby/services/open_food_facts_service.dart';
import 'package:carby/theme/app_theme.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final OpenFoodFactsService _foodApi = OpenFoodFactsService();

  bool _scanning = true;
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _lang =>
      context.read<UserProvider>().profile?.language ?? 'de';

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _loading) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    setState(() {
      _scanning = false;
      _loading = true;
      _errorText = null;
    });
    await _controller.stop();

    final food = await _foodApi.lookupBarcode(barcode);

    if (!mounted) return;

    if (food != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)),
      );
    } else {
      setState(() {
        _loading = false;
        _errorText = _lang == 'de'
            ? 'Produkt nicht gefunden ($barcode).\nBitte erneut versuchen.'
            : 'Product not found ($barcode).\nPlease try again.';
      });
    }
  }

  Future<void> _retry() async {
    setState(() {
      _scanning = true;
      _loading = false;
      _errorText = null;
    });
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final lang = _lang;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang == 'de' ? 'Barcode scannen' : 'Scan barcode',
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Viewfinder overlay
          _ScanOverlay(),

          // Bottom hint
          if (!_loading && _errorText == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Text(
                  lang == 'de'
                      ? 'Barcode in den Rahmen halten'
                      : 'Hold barcode inside the frame',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          // Loading spinner
          if (_loading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.orange),
                    const SizedBox(height: 16),
                    Text(
                      lang == 'de' ? 'Produkt wird gesucht…' : 'Looking up product…',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

          // Error state
          if (_errorText != null)
            Container(
              color: Colors.black87,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off,
                          color: AppColors.textSecondary, size: 56),
                      const SizedBox(height: 16),
                      Text(
                        _errorText!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 15, height: 1.5),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _retry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                        ),
                        child: Text(
                          lang == 'de' ? 'Erneut scannen' : 'Scan again',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      const frameSize = 260.0;
      final left = (size.width - frameSize) / 2;
      final top = (size.height - frameSize) / 2 - 40;

      return CustomPaint(
        size: size,
        painter: _OverlayPainter(
          frameRect: Rect.fromLTWH(left, top, frameSize, frameSize),
        ),
      );
    });
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect frameRect;
  const _OverlayPainter({required this.frameRect});

  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()..color = Colors.black.withOpacity(0.55);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, dimPaint);

    // Corner brackets
    const cornerLen = 24.0;
    const strokeW = 3.0;
    final cornerPaint = Paint()
      ..color = AppColors.orange
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corners = [
      // top-left
      [frameRect.topLeft, Offset(frameRect.left + cornerLen, frameRect.top),
       frameRect.topLeft, Offset(frameRect.left, frameRect.top + cornerLen)],
      // top-right
      [frameRect.topRight, Offset(frameRect.right - cornerLen, frameRect.top),
       frameRect.topRight, Offset(frameRect.right, frameRect.top + cornerLen)],
      // bottom-left
      [frameRect.bottomLeft, Offset(frameRect.left + cornerLen, frameRect.bottom),
       frameRect.bottomLeft, Offset(frameRect.left, frameRect.bottom - cornerLen)],
      // bottom-right
      [frameRect.bottomRight, Offset(frameRect.right - cornerLen, frameRect.bottom),
       frameRect.bottomRight, Offset(frameRect.right, frameRect.bottom - cornerLen)],
    ];

    for (final c in corners) {
      canvas.drawLine(c[0], c[1], cornerPaint);
      canvas.drawLine(c[2], c[3], cornerPaint);
    }

    // Scan line
    final linePaint = Paint()
      ..color = AppColors.orange.withOpacity(0.7)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(frameRect.left + 12, frameRect.center.dy),
      Offset(frameRect.right - 12, frameRect.center.dy),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
