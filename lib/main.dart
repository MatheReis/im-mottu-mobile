import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:im_mottu_mobile/app_widget.dart';
import 'package:im_mottu_mobile/controllers/app_controller.dart';
import 'package:im_mottu_mobile/services/native_connectivity_service.dart';
import 'package:im_mottu_mobile/controllers/connectivity_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appController = AppController();
  Get.put(appController);

  await initializeConnectivity();

  runApp(const AppWidget());
}

Future<void> initializeConnectivity() async {
  final nativeConn = await NativeConnectivityService().init();
  Get.put<NativeConnectivityService>(nativeConn);
  Get.put(ConnectivityController(nativeConn));
}
