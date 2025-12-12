import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../routes/app_routes.dart';
import '../../services/firestore_signaling_service.dart';

class LobbyController extends GetxController {
  final roomId = ''.obs;
  final inProgress = false.obs;
  final _uuid = const Uuid();

  FirestoreSignalingService get signaling => Get.find<FirestoreSignalingService>();

  void createRoomAndStartCall() async {
    inProgress.value = true;
    final id = _uuid.v4().substring(0, 8);
    roomId.value = id;
    await signaling.createRoom(id);
    inProgress.value = false;
    Get.toNamed(Routes.call, arguments: {'roomId': id, 'isCaller': true});
  }

  void joinRoom(String id) async {
    if (id.isEmpty) return;
    inProgress.value = true;
    roomId.value = id;
    final exists = await signaling.roomExists(id);
    inProgress.value = false;
    if (exists) {
      Get.toNamed(Routes.call, arguments: {'roomId': id, 'isCaller': false});
    } else {
      Get.snackbar('Room not found', 'Check the room ID and try again');
    }
  }
}
