# Task Management App Tests

This directory contains unit tests for the Task Management App. The tests are organized to match the structure of the main application code.

## Test Structure

```
test/
├── all_tests.dart          # Main entry point to run all tests
├── models/                # Tests for data models
│   ├── task_test.dart
│   ├── tag_test.dart
│   └── reminder_test.dart
├── controllers/           # Tests for controllers
│   ├── task_controller_test.dart
│   ├── tag_controller_test.dart
│   └── reminder_controller_test.dart
├── services/              # Tests for services
│   ├── connectivity_service_test.dart
│   └── database_service_test.dart
└── helpers/               # Test helpers and mocks
    └── mock_database_service.dart
```

## Running Tests

You can run all tests with the following command:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/models/task_test.dart
```

To run all tests with coverage:

```bash
flutter test --coverage
```

## Test Coverage

The test suite covers:

1. **Models**: Testing model creation, JSON serialization/deserialization, and utility methods
2. **Controllers**: Testing CRUD operations and business logic
3. **Services**: Testing database operations and connectivity monitoring

## Mocking Strategy

The tests use Mockito for mocking dependencies. The `MockDatabaseService` class provides a mock implementation of the database service for testing controllers without requiring a real database connection.

## Adding New Tests

When adding new features to the app:

1. Create corresponding test files in the appropriate directories
2. Follow the existing patterns for test organization
3. Update the `all_tests.dart` file to include your new test files