import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

/// Configuration for image cropping
class CropConfig {
  final String title;
  final CropAspectRatioPreset? initialAspectRatio;
  final List<CropAspectRatioPreset> aspectRatioPresets;
  final bool lockAspectRatio;
  final int? maxWidth;
  final int? maxHeight;
  final int compressQuality;

  const CropConfig({
    this.title = 'Crop Image',
    this.initialAspectRatio,
    this.aspectRatioPresets = const [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ],
    this.lockAspectRatio = false,
    this.maxWidth,
    this.maxHeight,
    this.compressQuality = 90,
  });

  /// Preset for profile photos (square, 512x512)
  static const CropConfig profilePhoto = CropConfig(
    title: 'Crop Profile Photo',
    initialAspectRatio: CropAspectRatioPreset.square,
    aspectRatioPresets: [CropAspectRatioPreset.square],
    lockAspectRatio: true,
    maxWidth: 512,
    maxHeight: 512,
    compressQuality: 90,
  );

  /// Preset for progress photos (flexible aspect ratio)
  static const CropConfig progressPhoto = CropConfig(
    title: 'Crop Progress Photo',
    initialAspectRatio: CropAspectRatioPreset.original,
    aspectRatioPresets: [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio3x2,
    ],
    lockAspectRatio: false,
    maxWidth: 1920,
    maxHeight: 1920,
    compressQuality: 85,
  );

  /// Preset for meal photos (flexible aspect ratio)
  static const CropConfig mealPhoto = CropConfig(
    title: 'Crop Meal Photo',
    initialAspectRatio: CropAspectRatioPreset.original,
    aspectRatioPresets: [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio4x3,
    ],
    lockAspectRatio: false,
    maxWidth: 1920,
    maxHeight: 1920,
    compressQuality: 85,
  );
}

/// Service for cropping images before upload
class ImageCropperService {
  /// Crop an image file with the given configuration
  /// Returns the cropped file or null if cancelled
  Future<File?> cropImage({
    required File imageFile,
    required BuildContext context,
    CropConfig config = const CropConfig(),
  }) async {
    final colorScheme = Theme.of(context).colorScheme;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      maxWidth: config.maxWidth,
      maxHeight: config.maxHeight,
      compressQuality: config.compressQuality,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: config.title,
          toolbarColor: colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: colorScheme.primary,
          backgroundColor: Colors.black,
          dimmedLayerColor: Colors.black54,
          cropFrameColor: colorScheme.primary,
          cropGridColor: Colors.white70,
          initAspectRatio: config.initialAspectRatio ?? CropAspectRatioPreset.original,
          lockAspectRatio: config.lockAspectRatio,
          aspectRatioPresets: config.aspectRatioPresets,
          hideBottomControls: false,
          showCropGrid: true,
        ),
        IOSUiSettings(
          title: config.title,
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          aspectRatioLockEnabled: config.lockAspectRatio,
          resetAspectRatioEnabled: !config.lockAspectRatio,
          aspectRatioPickerButtonHidden: config.lockAspectRatio,
          aspectRatioPresets: config.aspectRatioPresets,
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(width: 520, height: 520),
        ),
      ],
    );

    if (croppedFile == null) return null;
    return File(croppedFile.path);
  }

  /// Show a dialog asking if the user wants to crop the image
  /// Returns the cropped file, original file, or null if cancelled
  Future<File?> showCropOptionDialog({
    required File imageFile,
    required BuildContext context,
    CropConfig config = const CropConfig(),
  }) async {
    final result = await showDialog<_CropDialogResult>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Photo'),
        content: const Text('Would you like to crop this photo before uploading?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _CropDialogResult.cancel),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _CropDialogResult.skip),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _CropDialogResult.crop),
            child: const Text('Crop'),
          ),
        ],
      ),
    );

    switch (result) {
      case _CropDialogResult.crop:
        return cropImage(
          imageFile: imageFile,
          context: context,
          config: config,
        );
      case _CropDialogResult.skip:
        return imageFile;
      case _CropDialogResult.cancel:
      case null:
        return null;
    }
  }
}

enum _CropDialogResult {
  crop,
  skip,
  cancel,
}
