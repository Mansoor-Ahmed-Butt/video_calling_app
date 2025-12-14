import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';

import '../../services/firestore_signaling_service.dart';
import '../../services/webrtc_service.dart';

class CallController extends GetxController {
  late final WebRTCService _rtc;
  late final FirestoreSignalingService _signal;

  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();

  final micEnabled = true.obs;
  final camEnabled = true.obs;
  final speakerEnabled = true.obs;
  final connecting = true.obs;
  final hasLocalStream = false.obs;

  String get roomId => (Get.arguments?['roomId'] as String?) ?? '';
  bool get isCaller => (Get.arguments?['isCaller'] as bool?) ?? false;

  StreamSubscription? _iceSub;
  StreamSubscription? _remoteIceSub;

  @override
  void onInit() {
    super.onInit();
    _rtc = Get.find<WebRTCService>();
    _signal = Get.find<FirestoreSignalingService>();
  }

  /// Working with call setup and signaling
  @override
  Future<void> onReady() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    try {
      await _rtc.setup(localRenderer, remoteRenderer);
      hasLocalStream.value = _rtc.hasLocalVideo;

      // Subscribe to local ICE and remote ICE early so we don't miss candidates
      _iceSub = _rtc.onIceCandidate.listen((c) => _signal.addIceCandidate(roomId, c));
      _remoteIceSub = _signal.onRemoteIce(roomId).listen((c) => _rtc.addRemoteIceCandidate(c));

      if (isCaller) {
        final offer = await _rtc.createOffer();
        await _signal.setOffer(roomId, offer);
        _subscribeToRemoteAnswer();
      } else {
        final offer = await _signal.waitForOffer(roomId);
        await _rtc.setRemoteDescription(offer);
        final answer = await _rtc.createAnswer();
        await _signal.setAnswer(roomId, answer);
      }

      // subscriptions already created above
    } catch (e) {
      // Surface a user-friendly error and bail out to previous screen
      Get.snackbar('Call error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      connecting.value = false;
      await localRenderer.dispose();
      await remoteRenderer.dispose();
      Get.back();
      return;
    }
    connecting.value = false;
  }

  void _subscribeToRemoteAnswer() async {
    final answer = await _signal.waitForAnswer(roomId);
    await _rtc.setRemoteDescription(answer);
  }

  void toggleMic() {
    micEnabled.toggle();
    _rtc.enableAudio(micEnabled.value);
  }

  void toggleCam() {
    camEnabled.toggle();
    _rtc.enableVideo(camEnabled.value);
  }

  void switchCamera() {
    _rtc.switchCamera();
  }

  Future<void> hangup() async {
    await _rtc.disposePeer();
    await _signal.endRoom(roomId);
    Get.back();
  }

  @override
  Future<void> onClose() async {
    await _iceSub?.cancel();
    await _remoteIceSub?.cancel();
    await localRenderer.dispose();
    await remoteRenderer.dispose();
    super.onClose();
  }
}
