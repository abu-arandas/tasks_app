import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/tag.dart';
import '../services/database_service.dart';
import '../utils/error_handler.dart';

class TagController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final RxList<Tag> tags = <Tag>[].obs;
  final RxBool isLoading = false.obs;
  final Uuid _uuid = const Uuid();
  final ErrorHandler _errorHandler = ErrorHandler();

  @override
  void onInit() {
    super.onInit();
    fetchTags();
  }

  // Fetch all tags from the database
  Future<void> fetchTags() async {
    isLoading.value = true;
    try {
      tags.value = await _databaseService.getTags();
      _errorHandler.log('Successfully fetched ${tags.length} tags', level: ErrorHandler.info);
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to load tags');
      _errorHandler.log('Error fetching tags', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new tag
  Future<void> addTag(String name, String color) async {
    if (name.trim().isEmpty) {
      _errorHandler.handleValidationError('Tag Name', 'Tag name cannot be empty');
      return;
    }

    isLoading.value = true;
    final tag = Tag(
      id: _uuid.v4(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );

    try {
      await _databaseService.insertTag(tag);
      await _databaseService.logChange('tag', tag.id, 'create', tag.toJson().toString());
      tags.add(tag);
      _errorHandler.showSuccessSnackbar('Success', 'Tag added successfully');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to add tag');
      _errorHandler.log('Error adding tag', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing tag
  Future<void> updateTag(Tag tag) async {
    if (tag.name.trim().isEmpty) {
      _errorHandler.handleValidationError('Tag Name', 'Tag name cannot be empty');
      return;
    }

    isLoading.value = true;
    try {
      await _databaseService.updateTag(tag);
      await _databaseService.logChange('tag', tag.id, 'update', tag.toJson().toString());

      final index = tags.indexWhere((t) => t.id == tag.id);
      if (index != -1) {
        tags[index] = tag;
      }
      _errorHandler.showSuccessSnackbar('Success', 'Tag updated successfully');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to update tag');
      _errorHandler.log('Error updating tag', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a tag
  Future<void> deleteTag(String id) async {
    isLoading.value = true;
    try {
      await _databaseService.deleteTag(id);
      await _databaseService.logChange('tag', id, 'delete', '{"id": "$id"}');
      tags.removeWhere((tag) => tag.id == id);
      _errorHandler.showSuccessSnackbar('Success', 'Tag deleted successfully');
    } catch (e, stackTrace) {
      _errorHandler.handleDatabaseError(e, customMessage: 'Failed to delete tag');
      _errorHandler.log('Error deleting tag', level: ErrorHandler.error, errors: e, stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // Get a tag by ID
  Tag? getTagById(String id) {
    final index = tags.indexWhere((tag) => tag.id == id);
    if (index != -1) {
      return tags[index];
    }
    return null;
  }

  // Get a list of predefined colors for tags
  List<Map<String, dynamic>> getPredefinedColors() {
    return [
      {'name': 'Red', 'value': '#F44336'},
      {'name': 'Pink', 'value': '#E91E63'},
      {'name': 'Purple', 'value': '#9C27B0'},
      {'name': 'Deep Purple', 'value': '#673AB7'},
      {'name': 'Indigo', 'value': '#3F51B5'},
      {'name': 'Blue', 'value': '#2196F3'},
      {'name': 'Light Blue', 'value': '#03A9F4'},
      {'name': 'Cyan', 'value': '#00BCD4'},
      {'name': 'Teal', 'value': '#009688'},
      {'name': 'Green', 'value': '#4CAF50'},
      {'name': 'Light Green', 'value': '#8BC34A'},
      {'name': 'Lime', 'value': '#CDDC39'},
      {'name': 'Yellow', 'value': '#FFEB3B'},
      {'name': 'Amber', 'value': '#FFC107'},
      {'name': 'Orange', 'value': '#FF9800'},
      {'name': 'Deep Orange', 'value': '#FF5722'},
      {'name': 'Brown', 'value': '#795548'},
      {'name': 'Grey', 'value': '#9E9E9E'},
      {'name': 'Blue Grey', 'value': '#607D8B'},
    ];
  }

  restoreTags(List<Tag> tags) {
    this.tags.value = tags;
    update();
  }
}
