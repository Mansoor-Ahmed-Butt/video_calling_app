import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class WebRTCService {
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  final _iceController = StreamController<RTCIceCandidate>.broadcast();

  Stream<RTCIceCandidate> get onIceCandidate => _iceController.stream;

  Future<void> setup(RTCVideoRenderer local, RTCVideoRenderer remote) async {
    // Ensure camera/microphone permissions before attempting getUserMedia
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    if (!camStatus.isGranted || !micStatus.isGranted) {
      throw Exception('Camera/Microphone permission not granted');
    }
    final config = {
      'iceServers': [
        {
          'urls': ['stun:stun.l.google.com:19302'],
        },
      ],
      'sdpSemantics': 'unified-plan',
    };
    _pc = await createPeerConnection(config);

    _pc!.onIceCandidate = (c) {
      if (!_iceController.isClosed) {
        _iceController.add(c);
      }
    };

    // Unified Plan: use onTrack to render remote media
    _pc!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        remote.srcObject = event.streams[0];
      }
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'},
      });
    } catch (e) {
      // Prevent hard crash; surface a controlled error
      throw Exception('Failed to acquire media: $e');
    }
    local.srcObject = _localStream;
    // Add local tracks under Unified Plan
    for (var track in _localStream!.getTracks()) {
      await _pc!.addTrack(track, _localStream!);
    }
    // Ensure transceivers exist for both audio and video
    await _pc!.addTransceiver(kind: RTCRtpMediaType.RTCRtpMediaTypeAudio);
    await _pc!.addTransceiver(kind: RTCRtpMediaType.RTCRtpMediaTypeVideo);
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
    _pc = null;
    _localStream = null;
  }
}

extension _FirstOrDefault<T> on List<T> {
  T? firstOrDefault() => isEmpty ? null : first;
}
