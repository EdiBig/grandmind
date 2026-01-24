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
  FoodSearchSource _selectedSource = FoodSearchSource.all;

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

    // Determine which provider to use based on source and query
    final AsyncValue<List<FoodItem>> results;

    if (trimmedQuery.isEmpty) {
      // Show custom foods when no search query
      results = ref.watch(userCustomFoodsProvider);
    } else if (_selectedCategory != null) {
      // Category filter only works with custom foods
      results = ref.watch(
        foodsByCategoryProvider(
          FoodSearchParams(query: trimmedQuery, category: _selectedCategory),
        ),
      );
    } else {
      // Use source-based search
      results = ref.watch(
        foodSearchBySourceProvider(
          FoodSearchBySourceParams(
            query: trimmedQuery,
            source: _selectedSource,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelection ? 'Select Food' : 'Food Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final scannedFood = await context.push<FoodItem>(
                RouteConstants.barcodeScanner,
              );

              if (!context.mounted) return;

              if (scannedFood != null) {
                if (widget.isSelection) {
                  context.pop(scannedFood);
                } else {
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
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search foods',
              hintText: 'e.g., chicken breast, rice, banana...',
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
            textInputAction: TextInputAction.search,
          ),
          const SizedBox(height: 12),

          // Source tabs (only show when searching)
          if (trimmedQuery.isNotEmpty) ...[
            _buildSourceTabs(colorScheme),
            const SizedBox(height: 12),
          ],

          // Category chips
          _buildCategoryChips(),
          const SizedBox(height: 16),

          // Results header
          if (trimmedQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _getResultsHeader(),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Results list
          results.when(
            data: (foods) {
              if (foods.isEmpty) {
                return _buildEmptyState(trimmedQuery, colorScheme);
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: foods.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = foods[index];
                  return _FoodItemTile(
                    item: item,
                    isSelection: widget.isSelection,
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
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                         color: colorScheme.error, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to search foods',
                      style: TextStyle(color: colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSourceTabs(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _SourceChip(
            label: 'All Sources',
            icon: Icons.public,
            isSelected: _selectedSource == FoodSearchSource.all,
            onSelected: () => setState(() => _selectedSource = FoodSearchSource.all),
          ),
          const SizedBox(width: 8),
          _SourceChip(
            label: 'USDA',
            icon: Icons.verified,
            isSelected: _selectedSource == FoodSearchSource.usda,
            onSelected: () => setState(() => _selectedSource = FoodSearchSource.usda),
            tooltip: 'Official USDA food database',
          ),
          const SizedBox(width: 8),
          _SourceChip(
            label: 'Branded',
            icon: Icons.shopping_bag_outlined,
            isSelected: _selectedSource == FoodSearchSource.openFoodFacts,
            onSelected: () => setState(() => _selectedSource = FoodSearchSource.openFoodFacts),
            tooltip: 'Packaged & branded products',
          ),
          const SizedBox(width: 8),
          _SourceChip(
            label: 'My Foods',
            icon: Icons.person_outline,
            isSelected: _selectedSource == FoodSearchSource.custom,
            onSelected: () => setState(() => _selectedSource = FoodSearchSource.custom),
            tooltip: 'Your custom foods',
          ),
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

  Widget _buildEmptyState(String query, ColorScheme colorScheme) {
    final isSearching = query.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.restaurant_menu,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'No foods found' : 'No custom foods yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try a different search term or add a custom food'
                  : 'Search for foods or create your own',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  String _getResultsHeader() {
    switch (_selectedSource) {
      case FoodSearchSource.usda:
        return 'Results from USDA FoodData Central';
      case FoodSearchSource.openFoodFacts:
        return 'Results from Open Food Facts';
      case FoodSearchSource.custom:
        return 'Your custom foods';
      case FoodSearchSource.all:
        return 'Searching all sources';
    }
  }
}

/// Source filter chip widget
class _SourceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;
  final String? tooltip;

  const _SourceChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final chip = FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: chip);
    }
    return chip;
  }
}

/// Food item list tile with source badge
class _FoodItemTile extends StatelessWidget {
  final FoodItem item;
  final bool isSelection;
  final VoidCallback onTap;

  const _FoodItemTile({
    required this.item,
    required this.isSelection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
      leading: _buildSourceBadge(colorScheme),
      title: Text(
        item.name,
        style: TextStyle(color: colorScheme.onSurface),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${item.calories.toStringAsFixed(0)} cal per ${item.servingSizeGrams.toStringAsFixed(0)}${item.servingSizeUnit ?? 'g'}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              _MacroBadge(
                label: 'P',
                value: item.proteinGrams,
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 8),
              _MacroBadge(
                label: 'C',
                value: item.carbsGrams,
                color: const Color(0xFF2196F3),
              ),
              const SizedBox(width: 8),
              _MacroBadge(
                label: 'F',
                value: item.fatGrams,
                color: const Color(0xFFFF9800),
              ),
            ],
          ),
        ],
      ),
      trailing: isSelection ? const Icon(Icons.add_circle_outline) : null,
      onTap: onTap,
    );
  }

  Widget _buildSourceBadge(ColorScheme colorScheme) {
    IconData icon;
    Color bgColor;
    String tooltip;

    if (item.isCustom) {
      icon = Icons.person;
      bgColor = colorScheme.tertiaryContainer;
      tooltip = 'Custom food';
    } else if (item.isVerified) {
      // USDA foods are verified
      icon = Icons.verified;
      bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.2);
      tooltip = 'USDA verified';
    } else {
      // OpenFoodFacts or other sources
      icon = Icons.shopping_bag;
      bgColor = colorScheme.secondaryContainer;
      tooltip = 'Branded product';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Macro nutrient badge
class _MacroBadge extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${value.toStringAsFixed(0)}g $label',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
