import 'dart:async';
import '../services/database_service.dart';
import 'error_handler.dart';

/// A utility class for optimizing database operations.
/// This class provides methods for batch operations, query optimization,
/// and performance monitoring of database operations.
class DatabaseOptimizer {
  // Singleton pattern
  static final DatabaseOptimizer _instance = DatabaseOptimizer._internal();
  factory DatabaseOptimizer() => _instance;
  DatabaseOptimizer._internal();

  final DatabaseService _databaseService = DatabaseService();
  final ErrorHandler _errorHandler = ErrorHandler();

  // Performance metrics
  final Map<String, List<int>> _queryExecutionTimes = {};

  /// Execute a database operation with performance tracking
  Future<T> executeWithPerformanceTracking<T>(
    String operationName,
    Future<T> Function() databaseOperation,
  ) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await databaseOperation();
      stopwatch.stop();
      _recordExecutionTime(operationName, stopwatch.elapsedMilliseconds);
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      _recordExecutionTime(operationName, stopwatch.elapsedMilliseconds);
      _errorHandler.log(
        'Database operation "$operationName" failed',
        level: ErrorHandler.error,
        errors: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Record execution time for a database operation
  void _recordExecutionTime(String operationName, int executionTimeMs) {
    if (!_queryExecutionTimes.containsKey(operationName)) {
      _queryExecutionTimes[operationName] = [];
    }
    _queryExecutionTimes[operationName]!.add(executionTimeMs);

    // Log slow queries (over 100ms)
    if (executionTimeMs > 100) {
      _errorHandler.log(
        'Slow database operation: "$operationName" took $executionTimeMs ms',
        level: ErrorHandler.warning,
      );
    }
  }

  /// Get average execution time for a database operation
  double getAverageExecutionTime(String operationName) {
    final times = _queryExecutionTimes[operationName];
    if (times == null || times.isEmpty) return 0;

    final sum = times.reduce((a, b) => a + b);
    return sum / times.length;
  }

  /// Execute multiple operations in a batch for better performance
  Future<List<dynamic>> executeBatch(List<Future<dynamic> Function()> operations) async {
    final database = await _databaseService.database;
    final batch = database.batch();

    final stopwatch = Stopwatch()..start();
    try {
      // Add all operations to the batch
      final futures = <Future<dynamic>>[];
      for (final operation in operations) {
        futures.add(operation());
      }

      // Execute all operations and wait for results
      final results = await Future.wait(futures);

      // Commit the batch
      await batch.commit();

      stopwatch.stop();
      _recordExecutionTime('batch_operation', stopwatch.elapsedMilliseconds);

      return results;
    } catch (e, stackTrace) {
      stopwatch.stop();
      _recordExecutionTime('batch_operation_failed', stopwatch.elapsedMilliseconds);
      _errorHandler.log(
        'Batch operation failed',
        level: ErrorHandler.error,
        errors: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Optimize a database query by adding appropriate indexes
  Future<void> optimizeQuery(String tableName, List<String> columnNames) async {
    final database = await _databaseService.database;

    try {
      // Create indexes for the specified columns
      for (final columnName in columnNames) {
        final indexName = '${tableName}_${columnName}_idx';
        await database.execute('CREATE INDEX IF NOT EXISTS $indexName ON $tableName ($columnName)');
      }

      _errorHandler.log(
        'Created indexes for table $tableName on columns ${columnNames.join(", ")}',
        level: ErrorHandler.info,
      );
    } catch (e, stackTrace) {
      _errorHandler.log(
        'Failed to create indexes for table $tableName',
        level: ErrorHandler.error,
        errors: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Vacuum the database to reclaim space and optimize performance
  Future<void> vacuumDatabase() async {
    final database = await _databaseService.database;

    try {
      await database.execute('VACUUM');
      _errorHandler.log(
        'Database vacuum completed successfully',
        level: ErrorHandler.info,
      );
    } catch (e, stackTrace) {
      _errorHandler.log(
        'Database vacuum failed',
        level: ErrorHandler.error,
        errors: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Analyze the database to update statistics used by the query planner
  Future<void> analyzeDatabase() async {
    final database = await _databaseService.database;

    try {
      await database.execute('ANALYZE');
      _errorHandler.log(
        'Database analyze completed successfully',
        level: ErrorHandler.info,
      );
    } catch (e, stackTrace) {
      _errorHandler.log(
        'Database analyze failed',
        level: ErrorHandler.error,
        errors: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get performance metrics for all tracked database operations
  Map<String, Map<String, dynamic>> getPerformanceMetrics() {
    final metrics = <String, Map<String, dynamic>>{};

    _queryExecutionTimes.forEach((operation, times) {
      if (times.isEmpty) return;

      final sum = times.reduce((a, b) => a + b);
      final avg = sum / times.length;
      final max = times.reduce((a, b) => a > b ? a : b);
      final min = times.reduce((a, b) => a < b ? a : b);

      metrics[operation] = {
        'count': times.length,
        'average_ms': avg,
        'max_ms': max,
        'min_ms': min,
        'total_ms': sum,
      };
    });

    return metrics;
  }

  /// Clear performance metrics
  void clearPerformanceMetrics() {
    _queryExecutionTimes.clear();
  }
}
