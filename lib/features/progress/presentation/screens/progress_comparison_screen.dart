import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/progress_photo.dart';
import '../providers/progress_providers.dart';

/// Screen for comparing progress photos side by side
class ProgressComparisonScreen extends ConsumerStatefulWidget {
  const ProgressComparisonScreen({super.key});

  @override
  ConsumerState<ProgressComparisonScreen> createState() =>
      _ProgressComparisonScreenState();
}

class _ProgressComparisonScreenState
    extends ConsumerState<ProgressComparisonScreen> {
  ProgressPhoto? _beforePhoto;
  ProgressPhoto? _afterPhoto;
  PhotoAngle? _filterAngle;
  bool _showSlider = false;
  double _sliderPosition = 0.5;

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(progressPhotosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Progress'),
        actions: [
          if (_beforePhoto != null && _afterPhoto != null)
            IconButton(
              icon: Icon(_showSlider ? Icons.view_column : Icons.compare),
              tooltip: _showSlider ? 'Side by Side' : 'Slider View',
              onPressed: () {
                setState(() {
                  _showSlider = !_showSlider;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _beforePhoto = null;
                _afterPhoto = null;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),
          const SizedBox(height: 8),

          // Main content
          Expanded(
            child: photosAsync.when(
              data: (photos) {
                // Filter photos by angle if selected
                final filteredPhotos = _filterAngle == null
                    ? photos
                    : photos.where((p) => p.angle == _filterAngle).toList();

                // Sort by date (oldest first for before, newest first for after)
                filteredPhotos.sort((a, b) => a.date.compareTo(b.date));

                if (filteredPhotos.length < 2) {
                  return _buildNotEnoughPhotosState(context);
                }

                return Column(
                  children: [
                    // Comparison view
                    Expanded(
                      flex: 3,
                      child: _buildComparisonView(context),
                    ),

                    // Photo selection
                    const Divider(height: 1),
                    Expanded(
                      flex: 2,
                      child: _buildPhotoSelector(context, filteredPhotos),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text('Error loading photos'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(progressPhotosProvider),
                      child: const Text('Retry'),
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          _buildFilterChip('Front', PhotoAngle.front),
          const SizedBox(width: 8),
          _buildFilterChip('Side', PhotoAngle.side),
          const SizedBox(width: 8),
          _buildFilterChip('Back', PhotoAngle.back),
          const SizedBox(width: 8),
          _buildFilterChip('Other', PhotoAngle.other),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, PhotoAngle? angle) {
    final isSelected = _filterAngle == angle;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterAngle = selected ? angle : null;
          // Reset selections when changing filter
          _beforePhoto = null;
          _afterPhoto = null;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildComparisonView(BuildContext context) {
    if (_beforePhoto == null || _afterPhoto == null) {
      return _buildEmptyComparisonState(context);
    }

    if (_showSlider) {
      return _buildSliderComparisonView(context);
    }

    return _buildSideBySideView(context);
  }

  Widget _buildSideBySideView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildPhotoCard(
              context,
              _beforePhoto!,
              'Before',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildPhotoCard(
              context,
              _afterPhoto!,
              'After',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderComparisonView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // After photo (full)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: _afterPhoto!.imageUrl,
                        fit: BoxFit.cover,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),

                    // Before photo (clipped)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ClipRect(
                        clipper: _SliderClipper(_sliderPosition * constraints.maxWidth),
                        child: CachedNetworkImage(
                          imageUrl: _beforePhoto!.imageUrl,
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          placeholder: (context, url) => Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),

                    // Slider line
                    Positioned(
                      left: _sliderPosition * constraints.maxWidth - 2,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 4,
                        color: AppColors.white,
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.swap_horiz,
                              color: AppColors.black.withValues(alpha: 0.54),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Labels
                    Positioned(
                      left: 8,
                      top: 8,
                      child: _buildLabel('Before'),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: _buildLabel('After'),
                    ),

                    // Gesture detector for slider
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _sliderPosition =
                              (details.localPosition.dx / constraints.maxWidth)
                                  .clamp(0.0, 1.0);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // Date labels
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM d, yyyy').format(_beforePhoto!.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                DateFormat('MMM d, yyyy').format(_afterPhoto!.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPhotoCard(
    BuildContext context,
    ProgressPhoto photo,
    String label,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: photo.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.error),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('MMM d, yyyy').format(photo.date),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPhotoSelector(BuildContext context, List<ProgressPhoto> photos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Select photos to compare',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              final isBeforeSelected = _beforePhoto?.id == photo.id;
              final isAfterSelected = _afterPhoto?.id == photo.id;
              final isSelected = isBeforeSelected || isAfterSelected;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isBeforeSelected) {
                        _beforePhoto = null;
                      } else if (isAfterSelected) {
                        _afterPhoto = null;
                      } else if (_beforePhoto == null) {
                        _beforePhoto = photo;
                      } else if (_afterPhoto == null) {
                        _afterPhoto = photo;
                        // Ensure before is older than after
                        if (_beforePhoto!.date.isAfter(_afterPhoto!.date)) {
                          final temp = _beforePhoto;
                          _beforePhoto = _afterPhoto;
                          _afterPhoto = temp;
                        }
                      } else {
                        // Replace after photo
                        _afterPhoto = photo;
                        if (_beforePhoto!.date.isAfter(_afterPhoto!.date)) {
                          final temp = _beforePhoto;
                          _beforePhoto = _afterPhoto;
                          _afterPhoto = temp;
                        }
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: isBeforeSelected
                                      ? AppColors.info
                                      : AppColors.success,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl: photo.thumbnailUrl,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  placeholder: (context, url) => Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    child: const Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d').format(photo.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isBeforeSelected ? AppColors.info : AppColors.success,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isBeforeSelected ? 'Before' : 'After',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyComparisonState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Select photos to compare',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap on photos below to select\n"Before" and "After" photos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotEnoughPhotosState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Not Enough Photos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You need at least 2 photos to compare.\nAdd more progress photos to use this feature.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// Custom clipper for the slider comparison view
class _SliderClipper extends CustomClipper<Rect> {
  final double width;

  _SliderClipper(this.width);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, width, size.height);
  }

  @override
  bool shouldReclip(_SliderClipper oldClipper) => width != oldClipper.width;
}
