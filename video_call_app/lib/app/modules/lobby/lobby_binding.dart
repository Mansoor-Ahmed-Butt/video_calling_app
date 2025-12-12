import 'package:get/get.dart';

import 'lobby_controller.dart';
import '../../services/firestore_signaling_service.dart';
import '../../services/webrtc_service.dart';

class LobbyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<WebRTCService>(WebRTCService());
    Get.put<FirestoreSignalingService>(FirestoreSignalingService());
    Get.put<LobbyController>(LobbyController());
  }
}
