import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'lobby_controller.dart';

class LobbyView extends GetView<LobbyController> {
  const LobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController joinController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Service')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Want to talk to the Customer service?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.inProgress.value ? null : controller.createRoomAndStartCall,
                      icon: const Icon(Icons.videocam),
                      label: const Text('Videocall'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: joinController,
              decoration: const InputDecoration(labelText: 'Join by Room ID', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => controller.joinRoom(joinController.text.trim()), child: const Text('Join Room')),
          ],
        ),
      ),
    );
  }
}
