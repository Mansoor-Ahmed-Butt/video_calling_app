import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  final _iceController = StreamController<RTCIceCandidate>.broadcast();

  Stream<RTCIceCandidate> get onIceCandidate => _iceController.stream;

  Future<void> setup(RTCVideoRenderer local, RTCVideoRenderer remote) async {
    final config = {
      'iceServers': [
        {
          'urls': ['stun:stun.l.google.com:19302'],
        },
      ],
    };
    _pc = await createPeerConnection(config);

    _pc!.onIceCandidate = (c) {
      _iceController.add(c);
    };
    _pc!.onAddStream = (stream) {
      remote.srcObject = stream;
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });
    local.srcObject = _localStream;
    await _pc!.addStream(_localStream!);
  }

  Future<RTCSessionDescription> createOffer() async {
    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);
    return offer;
  }

  Future<RTCSessionDescription> createAnswer() async {
    final answer = await _pc!.createAnswer();
    await _pc!.setLocalDescription(answer);
    return answer;
  }

  Future<void> setRemoteDescription(RTCSessionDescription desc) async {
    await _pc!.setRemoteDescription(desc);
  }

  Future<void> addRemoteIceCandidate(RTCIceCandidate c) async {
    await _pc!.addCandidate(c);
  }

  void enableAudio(bool enable) {
    _localStream?.getAudioTracks().forEach((t) => t.enabled = enable);
  }

  void enableVideo(bool enable) {
    _localStream?.getVideoTracks().forEach((t) => t.enabled = enable);
  }

  Future<void> switchCamera() async {
    final track = _localStream?.getVideoTracks().firstOrDefault();
    if (track != null) await Helper.switchCamera(track);
  }

  Future<void> disposePeer() async {
    await _pc?.close();
    await _localStream?.dispose();
    await _iceController.close();
    _pc = null;
    _localStream = null;
  }
}

extension _FirstOrDefault<T> on List<T> {
  T? firstOrDefault() => isEmpty ? null : first;
}
