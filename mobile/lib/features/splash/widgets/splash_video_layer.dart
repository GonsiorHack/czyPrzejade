import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../app/design_tokens.dart';

/// Wideo na pełnym ekranie (cover); pojawia się płynnie po pierwszej klatce.
class SplashVideoLayer extends StatelessWidget {
  const SplashVideoLayer({super.key, required this.controller, required this.visible});
  final VideoPlayerController controller;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: AppDurations.fadeFast,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}
