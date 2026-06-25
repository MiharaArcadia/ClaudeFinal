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
  final OpenFoodFactsService _foodApi = OpenFoodFactsService();
  final MobileScannerController _controller = MobileScannerController();
  bool _scanning = true;
  bool _loading = false;
  String? _errorMsg;

  String get _lang =>
      context.read<UserProvider>().profile?.language ?? 'de';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning || _loading) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() {
      _scanning = false;
      _loading = true;
      _errorMsg = null;
    });

    await _controller.stop();

    final food = await _foodApi.lookupBarcode(barcode.rawValue!);

    if (!mounted) return;

    if (food != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => FoodDetailScreen(food: food)),
      );
    } else {
      setState(() {
        _loading = false;
        _errorMsg = _lang == 'de'
            ? 'Produkt nicht gefunden. Bitte manuell suchen.'
            : 'Product not found. Please search manually.';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _scanning = true;
          _errorMsg = null;
        });
        await _controller.start();
      }
    }
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
          lang == 'de' ? 'Barcode scannen' : 'Scan Barcode',
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
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Viewfinder overlay
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.orange, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Hint text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  lang == 'de'
                      ? 'Barcode in den Rahmen halten'
                      : 'Hold barcode inside the frame',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              ),
            ),
          if (_errorMsg != null)
            Positioned(
              bottom: 140,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMsg!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
