import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/progress_photo.dart';
import '../providers/progress_providers.dart';
import 'photo_detail_screen.dart';

class ProgressPhotosScreen extends ConsumerStatefulWidget {
  const ProgressPhotosScreen({super.key});

  @override
  ConsumerState<ProgressPhotosScreen> createState() =>
      _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends ConsumerState<ProgressPhotosScreen> {
  PhotoAngle? _selectedAngle; // null = All

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(progressPhotosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Photos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),
          const SizedBox(height: 8),

          // Photos grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(progressPhotosProvider);
              },
              child: photosAsync.when(
                data: (photos) {
                  // Filter by selected angle
                  final filteredPhotos = _selectedAngle == null
                      ? photos
                      : photos
                          .where((p) => p.angle == _selectedAngle)
                          .toList();

                  if (filteredPhotos.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return _buildPhotosGrid(filteredPhotos);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Error loading photos'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          ref.invalidate(progressPhotosProvider);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPhotoSourcePicker(context),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add Photo'),
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
    final isSelected = _selectedAngle == angle;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedAngle = selected ? angle : null;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildPhotosGrid(List<ProgressPhoto> photos) {
    // Group photos by date
    final groupedPhotos = <String, List<ProgressPhoto>>{};
    for (var photo in photos) {
      final dateKey = DateFormat('yyyy-MM-dd').format(photo.date);
      groupedPhotos.putIfAbsent(dateKey, () => []).add(photo);
    }

    final sortedDates = groupedPhotos.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Newest first

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateKey = sortedDates[index];
        final datePhotos = groupedPhotos[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                DateFormat('EEEE, MMM d, yyyy').format(date),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: datePhotos.length,
              itemBuilder: (context, photoIndex) {
                final photo = datePhotos[photoIndex];
                return _buildPhotoGridItem(photo);
              },
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildPhotoGridItem(ProgressPhoto photo) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PhotoDetailScreen(photo: photo),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb
                ? Image.network(
                    photo.thumbnailUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      photo.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: photo.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
          ),
          // Angle badge
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getAngleLabel(photo.angle),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getAngleLabel(PhotoAngle angle) {
    switch (angle) {
      case PhotoAngle.front:
        return 'Front';
      case PhotoAngle.side:
        return 'Side';
      case PhotoAngle.back:
        return 'Back';
      case PhotoAngle.other:
        return 'Other';
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            _selectedAngle == null
                ? 'No Progress Photos'
                : 'No ${_getAngleLabel(_selectedAngle!)} Photos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your transformation with photos',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showPhotoSourcePicker(context),
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add First Photo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        _showPhotoMetadataDialogBytes(bytes);
        return;
      }

      final imageFile = File(pickedFile.path);
      _showPhotoMetadataDialog(imageFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPhotoMetadataDialog(File imageFile) {
    PhotoAngle selectedAngle = PhotoAngle.front;
    DateTime selectedDate = DateTime.now();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Photo Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Angle selection
              const Text('Photo Angle', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<PhotoAngle>(
                initialValue: selectedAngle,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: PhotoAngle.values.map((angle) {
                  return DropdownMenuItem(
                    value: angle,
                    child: Text(_getAngleLabel(angle)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedAngle = value;
                },
              ),
              const SizedBox(height: 16),

              // Date selection
              const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Notes
              const Text('Notes (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add notes about this photo...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _uploadPhoto(
                imageFile,
                selectedAngle,
                selectedDate,
                notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _showPhotoMetadataDialogBytes(Uint8List imageBytes) {
    PhotoAngle selectedAngle = PhotoAngle.front;
    DateTime selectedDate = DateTime.now();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Photo Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Photo Angle',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<PhotoAngle>(
                initialValue: selectedAngle,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: PhotoAngle.values.map((angle) {
                  return DropdownMenuItem(
                    value: angle,
                    child: Text(_getAngleLabel(angle)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) selectedAngle = value;
                },
              ),
              const SizedBox(height: 16),
              const Text('Date',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Notes (optional)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add notes about this photo...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _uploadPhotoBytes(
                imageBytes,
                selectedAngle,
                selectedDate,
                notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPhoto(
    File imageFile,
    PhotoAngle angle,
    DateTime date,
    String? notes,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to upload photos')),
        );
      }
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading photo...'),
              ],
            ),
          ),
        ),
      ),
    );

    final operations = ref.read(progressOperationsProvider.notifier);
    final photoId = await operations.uploadProgressPhoto(
      userId: userId,
      imageFile: imageFile,
      angle: angle,
      date: date,
      notes: notes,
    );

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (photoId != null) {
        setState(() {
          _selectedAngle = null;
        });
        ref.invalidate(progressPhotosProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload photo. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadPhotoBytes(
    Uint8List imageBytes,
    PhotoAngle angle,
    DateTime date,
    String? notes,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to upload photos')),
        );
      }
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading photo...'),
              ],
            ),
          ),
        ),
      ),
    );

    final operations = ref.read(progressOperationsProvider.notifier);
    final photoId = await operations.uploadProgressPhotoBytes(
      userId: userId,
      imageBytes: imageBytes,
      angle: angle,
      date: date,
      notes: notes,
    );

    if (mounted) {
      Navigator.pop(context);
      if (photoId != null) {
        setState(() {
          _selectedAngle = null;
        });
        ref.invalidate(progressPhotosProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload photo. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Progress Photos Tips'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📸 Best Practices:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Take photos in good lighting'),
              Text('• Use the same location each time'),
              Text('• Wear similar clothing for consistency'),
              Text('• Take photos at the same time of day'),
              Text('• Relax and maintain good posture'),
              SizedBox(height: 16),
              Text('🔄 Photo Angles:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Front: Face forward, arms at sides'),
              Text('• Side: Turn 90° to show profile'),
              Text('• Back: Show your back view'),
              Text('• Other: Any other helpful angle'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
