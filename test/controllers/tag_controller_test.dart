import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tasks_app/controllers/tag_controller.dart';
import 'package:tasks_app/models/tag.dart';
import '../helpers/mock_database_service.dart';

void main() {
  late TagController tagController;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    Get.put(mockDatabaseService);
    tagController = TagController();
  });

  tearDown(() {
    Get.reset();
  });

  group('TagController Tests', () {
    test('fetchTags loads tags from database', () async {
      // Arrange
      final now = DateTime.now();
      final tag1 = Tag(
        id: 'tag-1',
        name: 'Work',
        color: '#FF0000',
        createdAt: now,
      );
      final tag2 = Tag(
        id: 'tag-2',
        name: 'Personal',
        color: '#00FF00',
        createdAt: now,
      );
      mockDatabaseService.addMockTag(tag1);
      mockDatabaseService.addMockTag(tag2);

      // Act
      await tagController.fetchTags();

      // Assert
      expect(tagController.tags.length, 2);
      expect(tagController.tags[0].id, 'tag-1');
      expect(tagController.tags[1].id, 'tag-2');
    });

    test('addTag adds a tag to the database and updates the list', () async {
      // Act
      await tagController.addTag('Work', '#FF0000');

      // Assert
      expect(tagController.tags.length, 1);
      expect(tagController.tags[0].name, 'Work');
      expect(tagController.tags[0].color, '#FF0000');
    });

    test('updateTag updates a tag in the database and in the list', () async {
      // Arrange
      final now = DateTime.now();
      final tag = Tag(
        id: 'tag-1',
        name: 'Work',
        color: '#FF0000',
        createdAt: now,
      );
      mockDatabaseService.addMockTag(tag);
      await tagController.fetchTags();

      // Create updated tag
      final updatedTag = tag.copyWith(
        name: 'Updated Work',
        color: '#0000FF',
      );

      // Act
      await tagController.updateTag(updatedTag);

      // Assert
      expect(tagController.tags.length, 1);
      expect(tagController.tags[0].name, 'Updated Work');
      expect(tagController.tags[0].color, '#0000FF');
    });

    test('deleteTag removes a tag from the database and from the list', () async {
      // Arrange
      final now = DateTime.now();
      final tag = Tag(
        id: 'tag-1',
        name: 'Work',
        color: '#FF0000',
        createdAt: now,
      );
      mockDatabaseService.addMockTag(tag);
      await tagController.fetchTags();
      expect(tagController.tags.length, 1);

      // Act
      await tagController.deleteTag('tag-1');

      // Assert
      expect(tagController.tags.length, 0);
    });
  });
}
