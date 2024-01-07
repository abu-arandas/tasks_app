import 'package:get/get.dart';

import 'authentication.dart';
import 'task.dart';

class Bind implements Bindings {
  @override
  void dependencies() {
    Get.put(Authentication());
    Get.put(TaskController());
  }
}
