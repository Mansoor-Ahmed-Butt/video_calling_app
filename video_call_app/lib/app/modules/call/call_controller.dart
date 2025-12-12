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

  String get roomId => (Get.arguments?['roomId'] as String?) ?? '';
  bool get isCaller => (Get.arguments?['isCaller'] as bool?) ?? false;

  StreamSubscription? _iceSub;

  @override
  void onInit() {
    super.onInit();
    _rtc = Get.find<WebRTCService>();
    _signal = Get.find<FirestoreSignalingService>();
  }

  @override
  Future<void> onReady() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    await _rtc.setup(localRenderer, remoteRenderer);

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

    _iceSub = _rtc.onIceCandidate.listen((c) => _signal.addIceCandidate(roomId, c));
    _signal.onRemoteIce(roomId).listen((c) => _rtc.addRemoteIceCandidate(c));
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
    await localRenderer.dispose();
    await remoteRenderer.dispose();
    super.onClose();
  }
}
