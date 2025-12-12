import 'package:get/get.dart';

import '../modules/lobby/lobby_view.dart';
import '../modules/lobby/lobby_binding.dart';
import '../modules/call/call_view.dart';
import '../modules/call/call_binding.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.lobby;

  static final routes = <GetPage<dynamic>>[
    GetPage(name: Routes.lobby, page: () => const LobbyView(), binding: LobbyBinding()),
    GetPage(name: Routes.call, page: () => const CallView(), binding: CallBinding()),
  ];
}
