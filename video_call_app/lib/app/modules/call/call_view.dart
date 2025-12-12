import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'call_controller.dart';

class CallView extends GetView<CallController> {
  const CallView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${controller.roomId}'),
        actions: [
          IconButton(
            onPressed: controller.hangup,
            icon: const Icon(Icons.call_end, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(color: Colors.black, child: RTCVideoView(controller.remoteRenderer, mirror: false)),
                Positioned(
                  right: 12,
                  bottom: 12,
                  width: 140,
                  height: 200,
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade900),
                    child: ClipRRect(borderRadius: BorderRadius.circular(12), child: RTCVideoView(controller.localRenderer, mirror: true)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                Obx(() => _controlButton(icon: Icons.mic, label: 'Mute', active: controller.micEnabled.value, onTap: controller.toggleMic)),
                Obx(
                  () => _controlButton(icon: Icons.videocam_off, label: 'Enable', active: controller.camEnabled.value, onTap: controller.toggleCam),
                ),
                _controlButton(icon: Icons.cameraswitch, label: 'Switch', onTap: controller.switchCamera),
                _controlButton(icon: Icons.call_end, label: 'Hangup', color: Colors.red, onTap: controller.hangup),
                _controlButton(icon: Icons.chat_bubble, label: 'Chat'),
                _controlButton(icon: Icons.brush, label: 'Whiteboard'),
                _controlButton(icon: Icons.volume_up, label: 'Audio output'),
                _controlButton(icon: Icons.folder, label: 'File Share'),
                _controlButton(icon: Icons.screen_share, label: 'Screen Share'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({required IconData icon, required String label, Color? color, bool active = true, VoidCallback? onTap}) {
    final bg = color ?? (active ? Colors.black87 : Colors.grey.shade700);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
