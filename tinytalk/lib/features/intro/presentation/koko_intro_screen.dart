import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../app/localization/app_language.dart';
import '../../../core/widgets/primary_bouncy_button.dart';
import '../../../shared/providers/app_language_providers.dart';
import '../../../shared/providers/onboarding_providers.dart';
import '../../../shared/providers/service_providers.dart';

class KokoIntroScreen extends ConsumerStatefulWidget {
  const KokoIntroScreen({super.key});

  @override
  ConsumerState<KokoIntroScreen> createState() => _KokoIntroScreenState();
}

class _KokoIntroScreenState extends ConsumerState<KokoIntroScreen> {
  late VideoPlayerController _videoController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController =
        VideoPlayerController.asset('assets/video/intro-koko.mp4');

    await _videoController.initialize();
    await _videoController.setVolume(0);
    await _videoController.setLooping(false);

    _videoController.addListener(_onVideoTick);

    await _videoController.play();

    if (mounted) {
      setState(() => _videoReady = true);
    }

    // Play language-specific audio in parallel with the video
    final language = ref.read(appLanguageControllerProvider).valueOrNull;
    final audioPath = language == AppLanguage.english
        ? 'audio/en/layout/intro-english.mp3'
        : 'audio/es/layout/intro-es.mp3';
    await ref.read(audioServiceProvider).playAsset(audioPath);
  }

  void _onVideoTick() {
    final ctrl = _videoController;
    if (!ctrl.value.isPlaying &&
        ctrl.value.isInitialized &&
        ctrl.value.position >= ctrl.value.duration) {
      _complete();
    }
  }

  void _complete() {
    if (!mounted) return;
    ref.read(kokoIntroControllerProvider.notifier).completeIntro();
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoTick);
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = ref.watch(appCopyProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoReady)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          Positioned(
            bottom: 48,
            left: 40,
            right: 40,
            child: PrimaryBouncyButton(
              label: copy.continueLabel,
              onPressed: _complete,
            ),
          ),
        ],
      ),
    );
  }
}
