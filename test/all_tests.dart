// Main test file to run all tests

import 'package:flutter_test/flutter_test.dart';

// Import all test files
// Models
import 'models/task_test.dart' as task_model_test;
import 'models/tag_test.dart' as tag_model_test;
import 'models/reminder_test.dart' as reminder_model_test;

// Controllers
import 'controllers/task_controller_test.dart' as task_controller_test;
import 'controllers/tag_controller_test.dart' as tag_controller_test;
import 'controllers/reminder_controller_test.dart' as reminder_controller_test;

// Services
import 'services/connectivity_service_test.dart' as connectivity_service_test;
import 'services/database_service_test.dart' as database_service_test;

void main() {
  group('All Tests', () {
    // Run model tests
    group('Model Tests', () {
      task_model_test.main();
      tag_model_test.main();
      reminder_model_test.main();
    });

    // Run controller tests
    group('Controller Tests', () {
      task_controller_test.main();
      tag_controller_test.main();
      reminder_controller_test.main();
    });

    // Run service tests
    group('Service Tests', () {
      connectivity_service_test.main();
      database_service_test.main();
    });
  });
}
