import 'package:get/get.dart';

import 'call_controller.dart';

class CallBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CallController>(CallController());
  }
}
