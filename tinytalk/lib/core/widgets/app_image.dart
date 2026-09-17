import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../services/asset_manifest_service.dart';
import 'platform_asset_image.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    required this.path,
    this.size = 160,
    super.key,
  });

  final String path;
  final double size;

  static final _assetManifestService = AssetManifestService();

  @override
  Widget build(BuildContext context) {
    final placeholder = _ImagePlaceholder(size: size);

    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      );
    }

    return FutureBuilder<bool>(
      future: _assetManifestService.exists(path),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return placeholder;
        }

        if (path.toLowerCase().endsWith('.avif')) {
          return buildPlatformAssetImage(
            path: path,
            width: size,
            height: size,
            fit: BoxFit.contain,
            fallback: placeholder,
          );
        }

        return Image.asset(
          path,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => placeholder,
        );
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.sun.withValues(alpha: 0.24),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.image_rounded,
        size: size * 0.42,
        color: AppColors.coral,
      ),
    );
  }
}
