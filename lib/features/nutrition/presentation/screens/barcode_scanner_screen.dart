import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../data/services/openfoodfacts_service.dart';
import '../../domain/models/food_item.dart';

/// Barcode Scanner Screen
/// Allows users to scan product barcodes to quickly add food items
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final OpenFoodFactsService _openFoodFactsService = OpenFoodFactsService();

  bool _isProcessing = false;
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBarcodeDetect(BarcodeCapture capture) async {
    if (_isProcessing || _hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    // Stop the scanner
    await _controller.stop();

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Looking up product...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Look up the product
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to scan products')),
        );
        Navigator.of(context).pop(); // Close scanner
      }
      return;
    }

    final FoodItem? foodItem =
        await _openFoodFactsService.getProductByBarcode(code, userId);

    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog

      if (foodItem != null) {
        // Show product details and allow selection
        final shouldSelect = await showDialog<bool>(
          context: context,
          builder: (context) => _ProductDetailsDialog(foodItem: foodItem),
        );

        if (shouldSelect == true && mounted) {
          // Return the food item to the previous screen
          Navigator.of(context).pop(foodItem);
        } else {
          // Resume scanning
          setState(() {
            _isProcessing = false;
            _hasScanned = false;
          });
          await _controller.start();
        }
      } else {
        // Product not found
        final shouldRetry = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Product Not Found'),
            content: Text(
              'Could not find product with barcode: $code\n\nWould you like to try scanning again or create a custom food item?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Try Again'),
              ),
            ],
          ),
        );

        if (shouldRetry == true && mounted) {
          // Resume scanning
          setState(() {
            _isProcessing = false;
            _hasScanned = false;
          });
          await _controller.start();
        } else if (mounted) {
          Navigator.of(context).pop(); // Close scanner
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetect,
          ),
          // Scanner overlay
          CustomPaint(
            painter: _ScannerOverlay(),
            size: Size.infinite,
          ),
          // Instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Position the barcode within the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The barcode will be scanned automatically',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for scanner overlay
class _ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;

    // Draw dark overlay
    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final innerPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
        const Radius.circular(12),
      ));

    canvas.drawPath(
      Path.combine(PathOperation.difference, outerPath, innerPath),
      paint,
    );

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final double bracketLength = 30;

    // Top-left
    canvas.drawLine(
      Offset(left, top + bracketLength),
      Offset(left, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + bracketLength, top),
      bracketPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(left + scanAreaSize - bracketLength, top),
      Offset(left + scanAreaSize, top),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top),
      Offset(left + scanAreaSize, top + bracketLength),
      bracketPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(left, top + scanAreaSize - bracketLength),
      Offset(left, top + scanAreaSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaSize),
      Offset(left + bracketLength, top + scanAreaSize),
      bracketPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(left + scanAreaSize - bracketLength, top + scanAreaSize),
      Offset(left + scanAreaSize, top + scanAreaSize),
      bracketPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - bracketLength),
      Offset(left + scanAreaSize, top + scanAreaSize),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Product details dialog
class _ProductDetailsDialog extends StatelessWidget {
  final FoodItem foodItem;

  const _ProductDetailsDialog({required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        foodItem.name,
        style: const TextStyle(fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (foodItem.brand != null && foodItem.brand!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.business, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        foodItem.brand!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            const Text(
              'Nutrition Facts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Per ${foodItem.servingSizeGrams.toStringAsFixed(0)}${foodItem.servingSizeUnit ?? "g"}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            _buildNutrientRow('Calories', '${foodItem.calories.toStringAsFixed(0)} kcal'),
            _buildNutrientRow('Protein', '${foodItem.proteinGrams.toStringAsFixed(1)}g'),
            _buildNutrientRow('Carbs', '${foodItem.carbsGrams.toStringAsFixed(1)}g'),
            _buildNutrientRow('Fat', '${foodItem.fatGrams.toStringAsFixed(1)}g'),
            if (foodItem.fiberGrams > 0)
              _buildNutrientRow('Fiber', '${foodItem.fiberGrams.toStringAsFixed(1)}g'),
            if (foodItem.sugarGrams > 0)
              _buildNutrientRow('Sugar', '${foodItem.sugarGrams.toStringAsFixed(1)}g'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Add Food'),
        ),
      ],
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
