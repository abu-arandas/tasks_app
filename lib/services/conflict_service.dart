import 'package:get/get.dart';
import '../models/conflict.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../models/reminder.dart';
import 'firebase_service.dart';
import 'database_service.dart';
import '../utils/error_handler.dart';

class ConflictService extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final DatabaseService _databaseService = DatabaseService();
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();

  // Observable list of conflicts
  final RxList<Conflict> conflicts = <Conflict>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUnresolvedConflicts();
  }

  // Load all unresolved conflicts
  Future<void> loadUnresolvedConflicts() async {
    try {
      final conflictData = await _firebaseService.getUnresolvedConflicts();
      conflicts.value = conflictData.map((data) => Conflict.fromJson(data)).toList();
    } catch (e) {
      _errorHandler.showErrorSnackbar('Load Conflicts Failed', e.toString());
    }
  }

  // Check for conflicts between local and remote data
  Future<bool> checkForConflicts(String entityId, String entityType, Map<String, dynamic> localData) async {
    try {
      // Get remote data based on entity type
      Map<String, dynamic>? remoteData;

      switch (entityType) {
        case 'task':
          final task = await _firebaseService.getTask(entityId);
          remoteData = task?.toJson();
          break;
        // Add cases for other entity types as needed
      }

      // If remote data exists and differs from local data
      if (remoteData != null && _hasConflict(localData, remoteData)) {
        // Record the conflict
        await _firebaseService.recordConflict(entityId, entityType, localData, remoteData);
        await loadUnresolvedConflicts(); // Refresh conflicts list
        return true;
      }

      return false;
    } catch (e) {
      _errorHandler.showErrorSnackbar('Check Conflicts Failed', e.toString());
      return false;
    }
  }

  // Determine if there's a conflict between local and remote data
  bool _hasConflict(Map<String, dynamic> localData, Map<String, dynamic> remoteData) {
    // Compare updatedAt timestamps
    final localUpdated = DateTime.parse(localData['updatedAt']);
    final remoteUpdated = DateTime.parse(remoteData['updatedAt']);

    // If remote is newer, check for actual data differences
    if (remoteUpdated.isAfter(localUpdated)) {
      // Compare relevant fields based on entity type
      // This is a simplified comparison - in a real app, you'd do a deeper comparison
      if (localData['title'] != remoteData['title'] ||
          localData['description'] != remoteData['description'] ||
          localData['isCompleted'] != remoteData['isCompleted']) {
        return true;
      }
    }

    return false;
  }

  // Resolve a conflict by choosing local or remote version
  Future<void> resolveConflict(Conflict conflict, bool useLocalVersion) async {
    try {
      // Update data based on the chosen version
      final dataToUse = useLocalVersion ? conflict.localData : conflict.remoteData;

      // Update both local and remote storage
      switch (conflict.entityType) {
        case 'task':
          final task = Task.fromJson(dataToUse);
          await _databaseService.updateTask(task);
          await _firebaseService.saveTask(task);
          break;
        case 'tag':
          final tag = Tag.fromJson(dataToUse);
          await _databaseService.updateTag(tag);
          await _firebaseService.saveTag(tag);
          break;
        case 'reminder':
          final reminder = Reminder.fromJson(dataToUse);
          await _databaseService.updateReminder(reminder);
          await _firebaseService.saveReminder(reminder);
          break;
      }

      // Mark conflict as resolved
      await _firebaseService.resolveConflict(conflict.id);

      // Update local conflicts list
      conflicts.removeWhere((c) => c.id == conflict.id);

      _errorHandler.showSuccessSnackbar('Conflict Resolved', 'Data has been synchronized');
    } catch (e) {
      _errorHandler.showErrorSnackbar('Resolve Conflict Failed', e.toString());
    }
  }

  // Create a merged version from local and remote data
  Future<void> mergeAndResolveConflict(Conflict conflict, Map<String, dynamic> mergedData) async {
    try {
      // Update both local and remote storage with merged data
      switch (conflict.entityType) {
        case 'task':
          final task = Task.fromJson(mergedData);
          await _databaseService.updateTask(task);
          await _firebaseService.saveTask(task);
          break;
        case 'tag':
          final tag = Tag.fromJson(mergedData);
          await _databaseService.updateTag(tag);
          await _firebaseService.saveTag(tag);
          break;
        case 'reminder':
          final reminder = Reminder.fromJson(mergedData);
          await _databaseService.updateReminder(reminder);
          await _firebaseService.saveReminder(reminder);
          break;
      }

      // Mark conflict as resolved
      await _firebaseService.resolveConflict(conflict.id);

      // Update local conflicts list
      conflicts.removeWhere((c) => c.id == conflict.id);

      _errorHandler.showSuccessSnackbar('Conflict Merged', 'Data has been merged and synchronized');
    } catch (e) {
      _errorHandler.showErrorSnackbar('Merge Conflict Failed', e.toString());
    }
  }
}
