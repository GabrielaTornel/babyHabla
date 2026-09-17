import 'package:flutter/material.dart';

import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';
import '../services/asset_manifest_service.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    this.width = 240,
    super.key,
  });

  final double width;

  static final _assetManifestService = AssetManifestService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _assetManifestService.exists(AppConstants.logoAssetPath),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return _LogoFallback(width: width);
        }

        return Image.asset(
          AppConstants.logoAssetPath,
          width: width,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return _LogoFallback(width: width);
          },
        );
      },
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppConstants.appName,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.roseMauve,
            fontSize: width * 0.17,
            fontWeight: FontWeight.w900,
          ),
    );
  }
}
