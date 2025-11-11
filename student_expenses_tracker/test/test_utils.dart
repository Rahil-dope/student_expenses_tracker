import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:student_expenses_tracker/database/database.dart';

/// Creates an in-memory AppDatabase for testing.
AppDatabase createTestDb() {
  final executor = NativeDatabase.memory();
  return AppDatabase(executor: executor);
}

/// A tiny in-memory FakeFirestore implementation used only for tests.
class FakeDocumentSnapshot {
  final String id;
  final Map<String, dynamic> _data;
  FakeDocumentSnapshot(this.id, this._data);
  Map<String, dynamic> data() => _data;
}

class FakeQuerySnapshot {
  final List<FakeDocumentSnapshot> docs;
  FakeQuerySnapshot(this.docs);
}

class FakeDocumentReference {
  final FakeFirestore _firestore;
  final List<String> _pathSegments;
  FakeDocumentReference(this._firestore, this._pathSegments);

  String get path => _pathSegments.join('/');

  Future<void> set(Map<String, dynamic> data, [Object? options]) async {
    _firestore._set(path, Map<String, dynamic>.from(data));
  }

  Future<FakeDocumentSnapshot> get() async {
    final data = _firestore._get(path);
    return FakeDocumentSnapshot(_pathSegments.last, data ?? {});
  }

  FakeCollectionReference collection(String name) => FakeCollectionReference(_firestore, [..._pathSegments, name]);
}

class FakeCollectionReference {
  final FakeFirestore _firestore;
  final List<String> _pathSegments;
  FakeCollectionReference(this._firestore, this._pathSegments);

  FakeDocumentReference doc(String id) => FakeDocumentReference(_firestore, [..._pathSegments, id]);

  Future<FakeQuerySnapshot> get() async {
    final prefix = _pathSegments.join('/');
    final entries = _firestore._listPrefix(prefix);
    final docs = entries.map((e) => FakeDocumentSnapshot(e.key.split('/').last, e.value)).toList();
    return FakeQuerySnapshot(docs);
  }
}

class FakeFirestore {
  final Map<String, Map<String, dynamic>> _storage = {};

  FakeCollectionReference collection(String name) => FakeCollectionReference(this, [name]);

  void _set(String path, Map<String, dynamic> data) {
    _storage[path] = data;
  }

  Map<String, dynamic>? _get(String path) => _storage[path];

  /// Public helper to set a document by full path (e.g. 'users/uid/expenses/id')
  void setDocument(String path, Map<String, dynamic> data) => _set(path, data);

  /// Public helper to get a document by full path.
  Map<String, dynamic>? getDocument(String path) => _get(path);

  Iterable<MapEntry<String, Map<String, dynamic>>> _listPrefix(String prefix) {
    final fullPrefix = prefix.endsWith('/') ? prefix : '$prefix/';
    return _storage.entries.where((e) => e.key.startsWith(fullPrefix)).map((e) => MapEntry(e.key, e.value));
  }
}

/// Creates a fake Firestore instance for tests.
FakeFirestore createFakeFirestore() => FakeFirestore();
