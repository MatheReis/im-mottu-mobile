import 'package:get/get.dart';
import 'package:im_mottu_mobile/services/native_connectivity_service.dart';

class ConnectivityController extends GetxController {
  final NativeConnectivityService _native;
  ConnectivityController(this._native);

  RxBool get isConnected => _native.isConnected;
}
