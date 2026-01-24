import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/models/food_item.dart';
import '../providers/nutrition_providers.dart';

class FoodSearchScreen extends ConsumerStatefulWidget {
  final bool isSelection;

  const FoodSearchScreen({super.key, this.isSelection = false});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  FoodCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateQuery(String value) {
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trimmedQuery = _query.trim();
    final AsyncValue<List<FoodItem>> results;

    if (trimmedQuery.isEmpty) {
      results = ref.watch(userCustomFoodsProvider);
    } else if (_selectedCategory != null) {
      results = ref.watch(
        foodsByCategoryProvider(
          FoodSearchParams(query: trimmedQuery, category: _selectedCategory),
        ),
      );
    } else {
      results = ref.watch(foodSearchProvider(trimmedQuery));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelection ? 'Select Food' : 'Food Search'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final scannedFood = await context.push<FoodItem>(
                RouteConstants.barcodeScanner,
              );

              if (!context.mounted) return;

              if (scannedFood != null) {
                if (widget.isSelection) {
                  // Return the scanned food to the previous screen
                  context.pop(scannedFood);
                } else {
                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Scanned: ${scannedFood.name}')),
                  );
                }
              }
            },
            tooltip: 'Scan Barcode',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteConstants.createCustomFood),
        icon: const Icon(Icons.add),
        label: const Text('Custom Food'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search foods',
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _updateQuery('');
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
            onChanged: _updateQuery,
          ),
          const SizedBox(height: 16),
          _buildCategoryChips(),
          const SizedBox(height: 16),
          results.when(
            data: (foods) {
              if (foods.isEmpty) {
                final emptyText = trimmedQuery.isEmpty
                    ? 'No custom foods yet'
                    : 'No foods match your search';
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      emptyText,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: foods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = foods[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    tileColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    subtitle: Text(
                      '${item.calories.toStringAsFixed(0)} cal - '
                      '${item.proteinGrams.toStringAsFixed(0)}g P - '
                      '${item.carbsGrams.toStringAsFixed(0)}g C - '
                      '${item.fatGrams.toStringAsFixed(0)}g F',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    trailing: widget.isSelection
                        ? const Icon(Icons.add_circle_outline)
                        : null,
                    onTap: () {
                      if (widget.isSelection) {
                        context.pop(item);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Selected ${item.name}')),
                        );
                      }
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Failed to load foods: $error'),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: _selectedCategory == null,
          onSelected: (_) => setState(() => _selectedCategory = null),
          selectedColor: colorScheme.primaryContainer,
          labelStyle: TextStyle(
            color: _selectedCategory == null
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
          ),
        ),
        ...FoodCategory.values.map(
          (category) => ChoiceChip(
            label: Text(category.displayName),
            selected: _selectedCategory == category,
            onSelected: (_) => setState(() => _selectedCategory = category),
            selectedColor: colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: _selectedCategory == category
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
