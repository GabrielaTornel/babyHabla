import 'package:audioplayers/audioplayers.dart';

import 'asset_manifest_service.dart';

class AudioService {
  AudioService({
    AssetManifestService? assetManifestService,
  })  : _assetManifestService = assetManifestService ?? AssetManifestService(),
        _player = AudioPlayer();

  final AudioPlayer _player;
  final AssetManifestService _assetManifestService;

  Future<bool> playAsset(String assetPath) async {
    // audioplayers expects paths relative to the assets folder.
    final fullAssetPath = 'assets/$assetPath';
    final assetExists = await _assetManifestService.exists(fullAssetPath);

    if (!assetExists) {
      return false;
    }

    await _player.stop();
    await _player.play(AssetSource(assetPath));
    return true;
  }

  Future<void> dispose() {
    return _player.dispose();
  }
}
