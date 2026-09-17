import 'dart:convert';

import 'package:flutter/services.dart';

class AssetManifestService {
  AssetManifestService({AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  Set<String>? _assetPaths;

  Future<bool> exists(String path) async {
    final paths = await _loadAssetPaths();
    return paths.contains(path);
  }

  Future<Set<String>> _loadAssetPaths() async {
    final cachedPaths = _assetPaths;
    if (cachedPaths != null) {
      return cachedPaths;
    }

    final manifestJson = await _assetBundle.loadString('AssetManifest.json');
    final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
    final paths = manifest.keys.toSet();

    _assetPaths = paths;
    return paths;
  }
}
