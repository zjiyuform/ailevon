import 'package:get/get.dart';
import 'package:ailevon/constants/constants.dart';
import 'package:ailevon/utils/dio_request.dart';

class RecordController extends GetxController {
  var isPaused = false.obs;

  Future<void> getIsPaused() async {
    isPaused.value =
        await dioRequest.getIsPaused("${HttpConstants.READHISTORY}/paused")
            as bool;
  }
}
