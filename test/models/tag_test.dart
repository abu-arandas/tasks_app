import 'package:flutter_test/flutter_test.dart';
import 'package:tasks_app/models/tag.dart';

void main() {
  group('Tag Model Tests', () {
    test('Tag creation with required fields', () {
      final now = DateTime.now();
      final tag = Tag(
        id: 'tag-id',
        name: 'Work',
        color: '#FF0000',
        createdAt: now,
      );

      expect(tag.id, 'tag-id');
      expect(tag.name, 'Work');
      expect(tag.color, '#FF0000');
      expect(tag.createdAt, now);
    });

    test('Tag.fromJson creates a Tag correctly', () {
      final now = DateTime.now();
      final nowString = now.toIso8601String();

      final json = {
        'id': 'tag-id',
        'name': 'Work',
        'color': '#FF0000',
        'createdAt': nowString,
      };

      final tag = Tag.fromJson(json);

      expect(tag.id, 'tag-id');
      expect(tag.name, 'Work');
      expect(tag.color, '#FF0000');
      expect(tag.createdAt.toIso8601String(), nowString);
    });

    test('Tag.toJson converts a Tag to JSON correctly', () {
      final now = DateTime.now();
      final tag = Tag(
        id: 'tag-id',
        name: 'Work',
        color: '#FF0000',
        createdAt: now,
      );

      final json = tag.toJson();

      expect(json['id'], 'tag-id');
      expect(json['name'], 'Work');
      expect(json['color'], '#FF0000');
      expect(json['createdAt'], now.toIso8601String());
    });

    test('Tag.copyWith creates a new Tag with updated fields', () {
      final now = DateTime.now();
      final original = Tag(
        id: 'tag-id',
        name: 'Work',
        color: '#FF0000',
        createdAt: now,
      );

      final updated = original.copyWith(
        name: 'Personal',
        color: '#00FF00',
      );

      // Original should be unchanged
      expect(original.name, 'Work');
      expect(original.color, '#FF0000');

      // Updated should have new values
      expect(updated.id, 'tag-id'); // Unchanged
      expect(updated.name, 'Personal');
      expect(updated.color, '#00FF00');
      expect(updated.createdAt, now); // Unchanged
    });
  });
}
