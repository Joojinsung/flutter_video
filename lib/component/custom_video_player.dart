import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:vod_player/component/custom_icon_button.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile? video;
  final GestureTapCallback onNewVideoPressed;

  const CustomVideoPlayer({
    required this.video,
    required this.onNewVideoPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoController;
  bool showControls = false;

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.video?.path != widget.video?.path) {
      initializeController();
    }
  }

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  initializeController() async {
    final videoController = VideoPlayerController.file(
      File(widget.video!.path),
    );

    await videoController.initialize();

    videoController.addListener(videoControllerListener);

    setState(() {
      this.videoController = videoController;
    });
  }

  // 재생 상태 변경될 때마다 재실행
  void videoControllerListener() {
    setState(() {});
  }

  // State가 폐기될 때 같이 폐기할 함수들
  @override
  void dispose() {
    videoController?.removeListener(videoControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) {
      return GestureDetector(
        onTap: () {
          setState(() {
            showControls = !showControls;
          });
        },
        child: CircularProgressIndicator(),
      );
    }
    return AspectRatio(
      aspectRatio: videoController!.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(
            videoController!,
          ),
          Align(
            alignment: Alignment.topRight,
            child: CustomIconButton(
              onPressed: widget.onNewVideoPressed,
              iconData: Icons.photo_camera_back,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomIconButton(
                  onPressed: onReversePressed,
                  iconData: Icons.rotate_left,
                ),
                CustomIconButton(
                  onPressed: onPlayPressed,
                  iconData: videoController!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                CustomIconButton(
                  onPressed: onForwardPressed,
                  iconData: Icons.rotate_right,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Slider(
              onChanged: (double val) {
                videoController!.seekTo(
                  Duration(seconds: val.toInt()),
                );
              },
              value: videoController!.value.position.inSeconds.toDouble(),
              min: 0,
              max: videoController!.value.duration.inSeconds.toDouble(),
            ),
          ),
        ],
      ),
    );
  }

  //AI 구현 / 아래에는 직접 구현한것
  // 재생 일시정지, 멈춤, 앞으로 가기
  // void onPlayPressed() {
  //   setState(() {
  //     if (videoController!.value.isPlaying) {
  //       videoController!.pause();
  //     } else {
  //       videoController!.play();
  //     }
  //   });
  // }
  //
  // void onReversePressed() {
  //   final currentPosition = videoController!.value.position;
  //   Duration newPosition = currentPosition - Duration(seconds: 3);
  //   if (newPosition.inSeconds < 0) newPosition = Duration.zero;
  //   videoController!.seekTo(newPosition);
  // }
  //
  void onForwardPressed() {
    final currentPosition = videoController!.value.position;
    final totalDuration = videoController!.value.duration;
    Duration newPosition = currentPosition + Duration(seconds: 3);
    if (newPosition > totalDuration) newPosition = totalDuration;
    videoController!.seekTo(newPosition);
  }

  // 되감기 버튼 눌렀을 때

  //되감기
  void onReversePressed() {
    final currentPosition = videoController!.value.position;
    Duration position = Duration(); //0 초로 실행위치 초기화

    if (currentPosition.inSeconds > 3) {
      position = currentPosition - Duration(seconds: 3);
    }
    videoController!.seekTo(position);
  }

  //앞으로 가기
  // void onForwardPressed() {
  //   final maxPosition = videoController!.value.duration; //동영상길이
  //   final currentPosition = videoController!.value.position;
  //   //동영상 길이로 실행 위치 초기화
  //   Duration position = maxPosition;
  //
  //   // 동영상 길이에서 3초를 뺀 값보다 현재 위치가 짧을 때만 3초 더하기
  //   if ((maxPosition - Duration(seconds: 3)).inSeconds >
  //       currentPosition.inSeconds) {
  //     position = currentPosition + Duration(seconds: 3);
  //   }
  // }

  // 재생버튼
  void onPlayPressed() {
    if (videoController!.value.isPlaying) {
      videoController!.pause();
    } else {
      videoController!.play();
    }
  }
}
