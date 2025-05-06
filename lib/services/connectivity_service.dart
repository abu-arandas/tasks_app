import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../utils/error_handler.dart';
import 'database_service.dart';

class ConnectivityService extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final DatabaseService _databaseService = DatabaseService();
  final RxBool isOnline = false.obs;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();
  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) => _updateConnectionStatus(result.first),
    );
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  // Initialize connectivity
  Future<void> _initConnectivity() async {
    try {
      await _connectivity.checkConnectivity().then((value) {
        ConnectivityResult result = value.first;
        _updateConnectionStatus(result);
      });
    } catch (e) {
      _errorHandler.showErrorSnackbar('Connectivity failed', 'Connectivity check failed: $e');
      isOnline.value = false;
    }
  }

  // Update connection status based on connectivity result
  void _updateConnectionStatus(ConnectivityResult result) {
    bool wasOffline = !isOnline.value;
    isOnline.value = result != ConnectivityResult.none;

    // If we just came back online, sync changes
    if (wasOffline && isOnline.value) {
      syncChanges();
    }
  }

  // Sync local changes with the server when back online
  Future<void> syncChanges() async {
    if (!isOnline.value) return;

    try {
      // Get all unsynced changes from the database
      final unsynced = await _databaseService.getUnsynced();

      // Process each change in order
      for (var change in unsynced) {
        // In a real app, this would send the change to a server API
        // For now, we'll just mark it as synced locally
        await _databaseService.markAsSynced(change['id']);

        // Example of how you would sync with a server:
        // final response = await http.post(
        //   Uri.parse('https://your-api.com/sync'),
        //   body: json.encode(change),
        //   headers: {'Content-Type': 'application/json'},
        // );
        //
        // if (response.statusCode == 200) {
        //   await _databaseService.markAsSynced(change['id']);
        // }
      }

      _errorHandler.showSuccessSnackbar('Synced', 'Synced ${unsynced.length} changes');
    } catch (e) {
      _errorHandler.showErrorSnackbar('Sync failed', e.toString());
    }
  }

  // Force a sync attempt (can be called manually by the user)
  Future<bool> forceSyncChanges() async {
    if (!isOnline.value) {
      return false;
    }

    await syncChanges();
    return true;
  }
}
