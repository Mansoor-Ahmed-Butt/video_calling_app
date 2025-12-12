import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class FirestoreSignalingService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rooms => _db.collection('rooms');

  Future<void> createRoom(String roomId) async {
    await _rooms.doc(roomId).set({'createdAt': FieldValue.serverTimestamp()});
  }

  Future<bool> roomExists(String roomId) async {
    final doc = await _rooms.doc(roomId).get();
    return doc.exists;
  }

  Future<void> setOffer(String roomId, RTCSessionDescription offer) async {
    await _rooms.doc(roomId).set({
      'offer': {'sdp': offer.sdp, 'type': offer.type},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setAnswer(String roomId, RTCSessionDescription answer) async {
    await _rooms.doc(roomId).set({
      'answer': {'sdp': answer.sdp, 'type': answer.type},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<RTCSessionDescription> waitForOffer(String roomId) async {
    final completer = Completer<RTCSessionDescription>();
    final sub = _rooms.doc(roomId).snapshots().listen((snap) {
      final data = snap.data();
      final offer = data?['offer'];
      if (offer != null) {
        completer.complete(RTCSessionDescription(offer['sdp'], offer['type']));
      }
    });
    final result = await completer.future;
    await sub.cancel();
    return result;
  }

  Future<RTCSessionDescription> waitForAnswer(String roomId) async {
    final completer = Completer<RTCSessionDescription>();
    final sub = _rooms.doc(roomId).snapshots().listen((snap) {
      final data = snap.data();
      final ans = data?['answer'];
      if (ans != null) {
        completer.complete(RTCSessionDescription(ans['sdp'], ans['type']));
      }
    });
    final result = await completer.future;
    await sub.cancel();
    return result;
  }

  Future<void> addIceCandidate(String roomId, RTCIceCandidate c) async {
    await _rooms.doc(roomId).collection('ice').add({
      'candidate': c.candidate,
      'sdpMid': c.sdpMid,
      'sdpMLineIndex': c.sdpMLineIndex,
      'ts': FieldValue.serverTimestamp(),
    });
  }

  Stream<RTCIceCandidate> onRemoteIce(String roomId) {
    return _rooms
        .doc(roomId)
        .collection('ice')
        .orderBy('ts', descending: false)
        .snapshots()
        .map(
          (qs) => qs.docs.map((d) {
            final data = d.data();
            return RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
          }),
        )
        .expand((it) => it);
  }

  Future<void> endRoom(String roomId) async {
    final batch = _db.batch();
    final roomRef = _rooms.doc(roomId);
    final ice = await roomRef.collection('ice').get();
    for (final doc in ice.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(roomRef);
    await batch.commit();
  }
}
