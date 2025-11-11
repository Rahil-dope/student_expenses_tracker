import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

/// Sync service for bidirectional sync between local Drift DB and Firestore.
/// Handles upload, download, conflict resolution (timestamp-based), and soft deletes.
class SyncService {
  final AppDatabase db;
  final dynamic firestore;

  SyncService({required this.db, required this.firestore});

  /// Upload a single expense to Firestore. Uses `updatedAt` for conflict resolution.
  Future<void> uploadExpense(String uid, Expense expense) async {
    if (expense.deleted) {
      // Soft delete: mark as deleted in Firestore
      await firestore
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .doc(expense.id)
          .set({'deleted': true, 'updatedAt': DateTime.now().toIso8601String()}, SetOptions(merge: true));
    } else {
      await firestore.collection('users').doc(uid).collection('expenses').doc(expense.id).set({
        'id': expense.id,
        'amount': expense.amount,
        'title': expense.title,
        'categoryId': expense.categoryId,
        'date': expense.date.toIso8601String(),
        'note': expense.note,
        'currency': expense.currency,
        'isRecurring': expense.isRecurring,
        'receiptPath': expense.receiptPath,
        'updatedAt': expense.updatedAt.toIso8601String(),
        'deleted': false,
      }, SetOptions(merge: true));
    }
  }

  /// Download all expenses for the user and merge with local DB.
  /// Conflict resolution: prefer the record with the newer `updatedAt`.
  Future<void> downloadAndMergeExpenses(String uid) async {
    try {
      final snapshot = await firestore.collection('users').doc(uid).collection('expenses').get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final remoteId = data['id'] as String;
        final remoteUpdatedAt = DateTime.parse(data['updatedAt'] as String? ?? DateTime.now().toIso8601String());
        final remoteDeleted = data['deleted'] as bool? ?? false;

        // Fetch local expense using custom query
        final localExpense = await (db.select(db.expenses)..where((e) => e.id.equals(remoteId))).getSingleOrNull();

        if (localExpense == null) {
          // New remote expense: insert locally
          if (!remoteDeleted) {
            await db.into(db.expenses).insert(ExpensesCompanion(
              id: Value(remoteId),
              amount: Value(data['amount'] as double),
              title: Value(data['title'] as String),
              categoryId: Value(data['categoryId'] as int),
              date: Value(DateTime.parse(data['date'] as String)),
              note: Value(data['note'] as String?),
              currency: Value(data['currency'] as String? ?? 'USD'),
              isRecurring: Value(data['isRecurring'] as bool? ?? false),
              receiptPath: Value(data['receiptPath'] as String?),
              updatedAt: Value(remoteUpdatedAt),
              deleted: Value(false),
            ));
          }
        } else {
          // Compare timestamps: merge if remote is newer
          if (remoteUpdatedAt.isAfter(localExpense.updatedAt)) {
            await db.into(db.expenses).insertOnConflictUpdate(ExpensesCompanion(
              id: Value(remoteId),
              amount: Value(data['amount'] as double),
              title: Value(data['title'] as String),
              categoryId: Value(data['categoryId'] as int),
              date: Value(DateTime.parse(data['date'] as String)),
              note: Value(data['note'] as String?),
              currency: Value(data['currency'] as String? ?? 'USD'),
              isRecurring: Value(data['isRecurring'] as bool? ?? false),
              receiptPath: Value(data['receiptPath'] as String?),
              updatedAt: Value(remoteUpdatedAt),
              deleted: Value(remoteDeleted),
            ));
          }
        }
      }
    } catch (e) {
      print('Error downloading expenses: $e');
      rethrow;
    }
  }

  /// Upload a single budget to Firestore.
  Future<void> uploadBudget(String uid, Budget budget) async {
    if (budget.deleted) {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .doc(budget.id)
          .set({'deleted': true, 'updatedAt': DateTime.now().toIso8601String()}, SetOptions(merge: true));
    } else {
      await firestore.collection('users').doc(uid).collection('budgets').doc(budget.id).set({
        'id': budget.id,
        'categoryId': budget.categoryId,
        'amount': budget.amount,
        'period': budget.period,
        'updatedAt': budget.updatedAt.toIso8601String(),
        'deleted': false,
      }, SetOptions(merge: true));
    }
  }

  /// Download and merge budgets with local DB.
  Future<void> downloadAndMergeBudgets(String uid) async {
    try {
      final snapshot = await firestore.collection('users').doc(uid).collection('budgets').get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final remoteId = data['id'] as String;
        final remoteUpdatedAt = DateTime.parse(data['updatedAt'] as String? ?? DateTime.now().toIso8601String());
        final remoteDeleted = data['deleted'] as bool? ?? false;

        final localBudget = await (db.select(db.budgets)..where((b) => b.id.equals(remoteId))).getSingleOrNull();

        if (localBudget == null) {
          if (!remoteDeleted) {
            await db.into(db.budgets).insert(BudgetsCompanion(
              id: Value(remoteId),
              categoryId: Value(data['categoryId'] as int),
              amount: Value(data['amount'] as double),
              period: Value(data['period'] as String? ?? 'monthly'),
              updatedAt: Value(remoteUpdatedAt),
              deleted: Value(false),
            ));
          }
        } else {
          if (remoteUpdatedAt.isAfter(localBudget.updatedAt)) {
            await db.into(db.budgets).insertOnConflictUpdate(BudgetsCompanion(
              id: Value(remoteId),
              categoryId: Value(data['categoryId'] as int),
              amount: Value(data['amount'] as double),
              period: Value(data['period'] as String? ?? 'monthly'),
              updatedAt: Value(remoteUpdatedAt),
              deleted: Value(remoteDeleted),
            ));
          }
        }
      }
    } catch (e) {
      print('Error downloading budgets: $e');
      rethrow;
    }
  }

  /// Full sync: upload all local changes, then download and merge remote.
  Future<void> runFullSync(String uid) async {
    try {
      print('[Sync] Starting full sync for user $uid');

      // Upload all local expenses and budgets
      final expenses = await db.getAllExpenses();
      final budgets = await db.getAllBudgets();

      for (final expense in expenses) {
        await uploadExpense(uid, expense);
      }
      for (final budget in budgets) {
        await uploadBudget(uid, budget);
      }

      // Download and merge remote data
      await downloadAndMergeExpenses(uid);
      await downloadAndMergeBudgets(uid);

      print('[Sync] Full sync completed');
    } catch (e) {
      print('[Sync] Error during full sync: $e');
      rethrow;
    }
  }
}
