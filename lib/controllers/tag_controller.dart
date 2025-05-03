import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/tag.dart';
import '../services/database_service.dart';

class TagController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final RxList<Tag> tags = <Tag>[].obs;
  final RxBool isLoading = false.obs;
  final Uuid _uuid = const Uuid();

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
    } catch (e) {
      print('Error fetching tags: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add a new tag
  Future<void> addTag(String name, String color) async {
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
    } catch (e) {
      print('Error adding tag: $e');
    }
  }

  // Update an existing tag
  Future<void> updateTag(Tag tag) async {
    try {
      await _databaseService.updateTag(tag);
      await _databaseService.logChange('tag', tag.id, 'update', tag.toJson().toString());

      final index = tags.indexWhere((t) => t.id == tag.id);
      if (index != -1) {
        tags[index] = tag;
      }
    } catch (e) {
      print('Error updating tag: $e');
    }
  }

  // Delete a tag
  Future<void> deleteTag(String id) async {
    try {
      await _databaseService.deleteTag(id);
      await _databaseService.logChange('tag', id, 'delete', '{"id": "$id"}');
      tags.removeWhere((tag) => tag.id == id);
    } catch (e) {
      print('Error deleting tag: $e');
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
}
