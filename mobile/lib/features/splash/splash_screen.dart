import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../app/design_tokens.dart';
import 'splash_constants.dart';
import 'widgets/splash_brand_title.dart';
import 'widgets/splash_skip_button.dart';
import 'widgets/splash_status_card.dart';
import 'widgets/splash_video_layer.dart';

/// Animacja startowa: odtwarza `assets/media/intro.mp4` bez dźwięku, na pełnym ekranie.
/// Podczas ładowania pokazuje nazwę marki, przy błędzie - ponowienie, zawsze - przycisk "Pomiń".
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinish});
  final VoidCallback onFinish;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

enum _Phase { loading, playing, failed }

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Timer? _watchdog;
  _Phase _phase = _Phase.loading;
  Duration _lastPosition = Duration.zero;
  Duration _stalledFor = Duration.zero;
  bool _finished = false;
  bool _videoProgressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  Future<void> _start() async {
    final old = _controller;
    _controller = null;
    await old?.dispose();
    if (!mounted || _finished) return;

    setState(() {
      _phase = _Phase.loading;
      _videoProgressed = false;
      _stalledFor = Duration.zero;
      _lastPosition = Duration.zero;
    });

    final controller = VideoPlayerController.asset(
      SplashConstants.asset,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _controller = controller;
    try {
      await controller.initialize();
      if (!mounted || _finished || _controller != controller) return;
      await controller.setVolume(0);
      await controller.setLooping(false);
      controller.addListener(_onVideoTick);
      await controller.play();
      if (!mounted) return;
      setState(() => _phase = _Phase.playing);
      _watchdog?.cancel();
      _watchdog = Timer.periodic(SplashConstants.stallCheckInterval, _checkStall);
    } catch (_) {
      _fail();
    }
  }

  void _onVideoTick() {
    final controller = _controller;
    if (controller == null || _finished) return;
    final value = controller.value;
    if (value.hasError) {
      _fail();
      return;
    }
    if (value.position > Duration.zero && !_videoProgressed) {
      setState(() => _videoProgressed = true);
    }
    final ended = value.duration > Duration.zero &&
        value.position >= value.duration - SplashConstants.endMargin;
    if (ended && _videoProgressed) _finish();
  }

  /// Watchdog: brak postępu pozycji przez [SplashConstants.stallTimeout] oznacza błąd.
  void _checkStall(Timer timer) {
    final controller = _controller;
    if (controller == null || _finished || _phase != _Phase.playing) return;
    final value = controller.value;
    if (value.position > _lastPosition) {
      _stalledFor = Duration.zero;
    } else if (value.isPlaying || value.isBuffering) {
      _stalledFor += SplashConstants.stallCheckInterval;
    }
    _lastPosition = value.position;
    if (_stalledFor >= SplashConstants.stallTimeout) _fail();
  }

  void _fail() {
    if (_finished || !mounted || _phase == _Phase.failed) return;
    _watchdog?.cancel();
    _controller?.pause();
    setState(() => _phase = _Phase.failed);
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _watchdog?.cancel();
    _controller?.pause();
    widget.onFinish();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || _finished || _phase != _Phase.playing) return;
    if (state == AppLifecycleState.resumed) {
      controller.play();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      controller.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _watchdog?.cancel();
    _controller?.removeListener(_onVideoTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final showVideo = controller != null && controller.value.isInitialized && _phase != _Phase.failed;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const SplashBrandTitle(),
          if (showVideo) SplashVideoLayer(controller: controller, visible: _videoProgressed),
          if (_phase == _Phase.loading)
            const Align(
              alignment: SplashConstants.statusAlignment,
              child: SplashStatusCard(
                child: Text(SplashStrings.loading, textAlign: TextAlign.center),
              ),
            ),
          if (_phase == _Phase.failed)
            Align(
              alignment: SplashConstants.statusAlignment,
              child: SplashStatusCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: Spacing.md,
                  children: [
                    const Text(SplashStrings.failed, textAlign: TextAlign.center),
                    FilledButton(onPressed: _start, child: const Text(SplashStrings.retry)),
                  ],
                ),
              ),
            ),
          SplashSkipButton(onPressed: _finish),
        ],
      ),
    );
  }
}
