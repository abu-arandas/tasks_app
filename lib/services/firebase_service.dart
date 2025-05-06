import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/task.dart';
import '../models/tag.dart';
import '../models/reminder.dart';
import '../utils/error_handler.dart';

class FirebaseService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ErrorHandler _errorHandler = Get.find<ErrorHandler>();

  // Authentication state
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isAuthenticated = false.obs;

  // Collection references
  late CollectionReference _tasksCollection;
  late CollectionReference _tagsCollection;
  late CollectionReference _remindersCollection;
  late CollectionReference _conflictsCollection;

  @override
  void onInit() {
    super.onInit();
    // Listen to authentication state changes
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Handle auth state changes
  void _onAuthStateChanged(User? firebaseUser) {
    user.value = firebaseUser;
    isAuthenticated.value = firebaseUser != null;

    if (isAuthenticated.value) {
      // Initialize user-specific collections
      _initUserCollections();
    }
  }

  // Initialize Firestore collections for the current user
  void _initUserCollections() {
    final String userId = user.value!.uid;
    _tasksCollection = _firestore.collection('users').doc(userId).collection('tasks');
    _tagsCollection = _firestore.collection('users').doc(userId).collection('tags');
    _remindersCollection = _firestore.collection('users').doc(userId).collection('reminders');
    _conflictsCollection = _firestore.collection('users').doc(userId).collection('conflicts');
  }

  // AUTHENTICATION METHODS

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _errorHandler.showErrorSnackbar('Sign In Failed', e.toString());
      return false;
    }
  }

  // Create a new account
  Future<bool> createUserWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _errorHandler.showErrorSnackbar('Sign Up Failed', e.toString());
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _errorHandler.showErrorSnackbar('Sign Out Failed', e.toString());
    }
  }

  // FIRESTORE CRUD OPERATIONS

  // Tasks
  Future<void> saveTask(Task task) async {
    if (!isAuthenticated.value) return;

    try {
      await _tasksCollection.doc(task.id).set(task.toJson());
    } catch (e) {
      _errorHandler.showErrorSnackbar('Save Task Failed', e.toString());
    }
  }

  Future<Task?> getTask(String taskId) async {
    if (!isAuthenticated.value) return null;

    try {
      final doc = await _tasksCollection.doc(taskId).get();
      if (doc.exists && doc.data() != null) {
        return Task.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      _errorHandler.showErrorSnackbar('Get Task Failed', e.toString());
    }
    return null;
  }

  Stream<List<Task>> tasksStream() {
    if (!isAuthenticated.value) {
      return Stream.value([]);
    }

    return _tasksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> deleteTask(String taskId) async {
    if (!isAuthenticated.value) return;

    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      _errorHandler.showErrorSnackbar('Delete Task Failed', e.toString());
    }
  }

  // Tags
  Future<void> saveTag(Tag tag) async {
    if (!isAuthenticated.value) return;

    try {
      await _tagsCollection.doc(tag.id).set(tag.toJson());
    } catch (e) {
      _errorHandler.showErrorSnackbar('Save Tag Failed', e.toString());
    }
  }

  Stream<List<Tag>> tagsStream() {
    if (!isAuthenticated.value) {
      return Stream.value([]);
    }

    return _tagsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Tag.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  // Reminders
  Future<void> saveReminder(Reminder reminder) async {
    if (!isAuthenticated.value) return;

    try {
      await _remindersCollection.doc(reminder.id).set(reminder.toJson());
    } catch (e) {
      _errorHandler.showErrorSnackbar('Save Reminder Failed', e.toString());
    }
  }

  Stream<List<Reminder>> remindersStream() {
    if (!isAuthenticated.value) {
      return Stream.value([]);
    }

    return _remindersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Reminder.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  // CONFLICT MANAGEMENT

  // Record a conflict for later resolution
  Future<void> recordConflict(
      String entityId, String entityType, Map<String, dynamic> localData, Map<String, dynamic> remoteData) async {
    if (!isAuthenticated.value) return;

    try {
      await _conflictsCollection.add({
        'entityId': entityId,
        'entityType': entityType,
        'localData': localData,
        'remoteData': remoteData,
        'createdAt': FieldValue.serverTimestamp(),
        'resolved': false
      });
    } catch (e) {
      _errorHandler.showErrorSnackbar('Record Conflict Failed', e.toString());
    }
  }

  // Get all unresolved conflicts
  Future<List<Map<String, dynamic>>> getUnresolvedConflicts() async {
    if (!isAuthenticated.value) return [];

    try {
      final snapshot = await _conflictsCollection.where('resolved', isEqualTo: false).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      _errorHandler.showErrorSnackbar('Get Conflicts Failed', e.toString());
      return [];
    }
  }

  // Mark a conflict as resolved
  Future<void> resolveConflict(String conflictId) async {
    if (!isAuthenticated.value) return;

    try {
      await _conflictsCollection.doc(conflictId).update({'resolved': true});
    } catch (e) {
      _errorHandler.showErrorSnackbar('Resolve Conflict Failed', e.toString());
    }
  }
}
