import 'package:flutter_test/flutter_test.dart';
import 'package:student_expenses_tracker/repositories/sync_service.dart';
import 'package:student_expenses_tracker/database/database.dart';
import 'package:drift/drift.dart' hide isNotNull;
import '../test_utils.dart';

void main() {
  group('SyncService integration tests (with FakeFirestore)', () {
    test('uploadExpense writes expense to FakeFirestore', () async {
      final db = createTestDb();
      final fakeFs = createFakeFirestore();
      final sync = SyncService(db: db, firestore: fakeFs as dynamic);

      // Insert a local expense
      final id = 'local-exp-1';
      final now = DateTime.now();

      await db.into(db.expenses).insert(ExpensesCompanion(
        id: Value(id),
        amount: Value(12.5),
        title: Value('Test Lunch'),
        categoryId: Value(1),
        date: Value(now),
        note: Value('Good'),
        currency: Value('USD'),
        isRecurring: Value(false),
        receiptPath: Value(null),
        updatedAt: Value(now),
        deleted: Value(false),
      ));

      final expenses = await db.getAllExpenses();
      expect(expenses.length, 1);
      final expense = expenses.first;

      final uid = 'user-123';
      await sync.uploadExpense(uid, expense);

      // Verify document present in fake firestore
  final docPath = 'users/$uid/expenses/$id';
  final doc = fakeFs.getDocument(docPath);
  expect(doc, isNotNull);
  expect(doc!['title'], 'Test Lunch');
  expect(doc['amount'], 12.5);
    });

    test('downloadAndMergeExpenses inserts remote expense into local DB', () async {
      final db = createTestDb();
      final fakeFs = createFakeFirestore();
      final sync = SyncService(db: db, firestore: fakeFs as dynamic);

      final uid = 'user-456';
      final remoteId = 'remote-exp-1';
      final remoteData = {
        'id': remoteId,
        'amount': 42.0,
        'title': 'Remote Coffee',
        'categoryId': 2,
        'date': DateTime.now().toIso8601String(),
        'note': 'From cafe',
        'currency': 'USD',
        'isRecurring': false,
        'receiptPath': null,
        'updatedAt': DateTime.now().toIso8601String(),
        'deleted': false,
      };

  // Put remote doc into fake firestore storage using public helper
  fakeFs.setDocument('users/$uid/expenses/$remoteId', Map<String, dynamic>.from(remoteData));

      // Run download and merge
      await sync.downloadAndMergeExpenses(uid);

      final local = await (db.select(db.expenses)..where((e) => e.id.equals(remoteId))).getSingleOrNull();
      expect(local, isNotNull);
      expect(local!.title, 'Remote Coffee');
      expect(local.amount, 42.0);
    });
  });
}
