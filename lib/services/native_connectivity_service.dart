import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class NativeConnectivityService extends GetxService {
  static const _channel = EventChannel('im_mottu/connectivity');

  final isConnected = true.obs;
  final isReady = false.obs;
  StreamSubscription? _sub;

  Future<NativeConnectivityService> init() async {
    _sub = _channel.receiveBroadcastStream().listen((event) {
      if (event is bool) {
        isConnected.value = event;
      }
    }, onError: (err) {
      if (kDebugMode) {
        print('Native connectivity error: $err');
      }
    });

    await Future.delayed(const Duration(milliseconds: 250));
    isReady.value = true;
    return this;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
