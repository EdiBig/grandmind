import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/services/openfoodfacts_service.dart';
import '../../domain/models/food_item.dart';

/// Barcode Lookup Screen
/// Manual barcode entry to avoid native ML Kit dependencies.
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  final OpenFoodFactsService _openFoodFactsService = OpenFoodFactsService();

  bool _isProcessing = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _lookupBarcode() async {
    if (_isProcessing) return;
    final code = _barcodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a barcode first')),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to look up products')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final FoodItem? foodItem =
        await _openFoodFactsService.getProductByBarcode(code, userId);

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });

    if (foodItem != null) {
      final shouldSelect = await showDialog<bool>(
        context: context,
        builder: (context) => _ProductDetailsDialog(foodItem: foodItem),
      );

      if (shouldSelect == true && mounted) {
        Navigator.of(context).pop(foodItem);
      }
    } else {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Product Not Found'),
          content: Text(
            'Could not find product with barcode: $code\n\n'
            'Please try again or add a custom food item.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Lookup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter a barcode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _lookupBarcode(),
              decoration: InputDecoration(
                hintText: 'e.g. 0123456789012',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _lookupBarcode,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.search),
                label: Text(_isProcessing ? 'Looking up...' : 'Look Up'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tip: You can paste a barcode from the label.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
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
        style: TextStyle(fontSize: 18),
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
                    Icon(Icons.business, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        foodItem.brand!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Divider(),
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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
